//
//  LogListViewModel.swift
//  LifeLogApp
//
//  Created by ShinUnuma on 2021/07/06.
//

import RxSwift

class LogListViewModel {
    let isLoading = BehaviorSubject<Bool>(value: false)
    let isEnableSave = PublishSubject<Bool>()
    let completedGetLogs = PublishSubject<Bool>()
    let searchResult = PublishSubject<Bool>()
    let completedCreate = PublishSubject<Bool>()
    let completedDelete = PublishSubject<Bool>()
    let errorMessage = PublishSubject<String>()
    let completedWrite = PublishSubject<URL>()
    private let logDetailDataStore: LogDetailDataStoreType
    private let disposeBag = DisposeBag()
    private var logs: [LogSection] = []
    private var searchLogs: [LogSection] = []
    private(set) var tagList: [Tag] = []
    private(set) var tag: Tag?
    private(set) var resultList: [LogSection] = []
    private(set) var sectionType: MainSectionType = .all
    private(set) var images: Set<String> = []
    private(set) var isMax = false
    private(set) var searchWord = ""
    var sectionCount: Int {
        return resultList.count
    }
    var isProgress: Bool {
        return (try? isLoading.value()) ?? false
    }
    var isTypeTags: Bool {
        return sectionType == .tags
    }
    private var offset = 0
    private let limit = 50
    
    init(logDetailDataStore: LogDetailDataStoreType = LogDetailDataStore()) {
        self.logDetailDataStore = logDetailDataStore
    }
    
    func setup(sectionType: MainSectionType, tagList: [Tag], tag: Tag?) {
        self.sectionType = sectionType
        self.tagList = tagList
        self.tag = tag
    }
    
    func fetchLogs() {
        isLoading.onNext(true)
        let observer = self.tag != nil ? logDetailDataStore.fetch(with: tag!, offset: offset, limit: limit) : logDetailDataStore.fetchAll(offset: offset, limit: limit)
        observer.subscribe(onSuccess: { [weak self] details in
            guard let self = self else { return }
            self.isLoading.onNext(false)
            self.isMax = details.count < self.limit
            self.logs = self.groupByCreateDay(details: details)
            self.resultList = self.logs
            self.completedGetLogs.onNext(self.resultList.isEmpty)
            self.offset += self.limit
        },
        onFailure: { [weak self] error in
            self?.isLoading.onNext(false)
            self?.errorMessage.onNext(error.message)
        })
        .disposed(by: disposeBag)
    }
    
    func create(text: String) {
        let tagNames = TagHelper.pickupTags(text: text)
        logDetailDataStore.create(text: text, tags: tagNames, images: images)
            .subscribe(onSuccess: { [weak self] logDetail in
                guard let self = self else { return }
                self.isEnableSave.onNext(true)
                var isNewSection = false
                if let logSection = self.logs.first(where: { logDetail.isSameSectionTitle(title: $0.dateLabel) }) {
                    logSection.addFirst(log: logDetail)
                } else {
                    let dateLabel = logDetail.logSectionTitle()
                    let logSection = LogSection(dateLabel: dateLabel, detail: logDetail)
                    self.logs.append(logSection)
                    isNewSection = true
                }
                self.resultList = self.logs
                self.addTag(tagNames: tagNames)
                self.completedCreate.onNext(isNewSection)
            },
            onFailure: { [weak self] error in
                self?.isEnableSave.onNext(true)
                self?.errorMessage.onNext(error.message)
            })
            .disposed(by: disposeBag)
    }
    
    func delete(logDetail: LogDetail) {
        isLoading.onNext(true)
        logDetailDataStore.delete(id: logDetail.id)
            .subscribe(onSuccess: { [weak self] in
                guard let self = self else { return }
                self.isLoading.onNext(false)
                guard let logSection = self.logs.first(where: { logDetail.isSameSectionTitle(title: $0.dateLabel) }) else {
                    return
                }
                logSection.remove(logDetail: logDetail)
                self.resultList = self.logs
                self.completedDelete.onNext(self.resultList.isEmpty)
            },
            onFailure: { [weak self] error in
                self?.isLoading.onNext(false)
                self?.errorMessage.onNext(error.message)
            })
            .disposed(by: disposeBag)
    }
    
    func logCount(section: Int) -> Int {
        return resultList[section].logs.count
    }
    
    func sectionTitle(section: Int) -> String? {
        let dateLabel = resultList[section].dateLabel
        return dateLabel
    }
    
    func logDetail(indexPath: IndexPath) -> LogDetail? {
        let section = indexPath.section
        let index = indexPath.row
        if !resultList.indices.contains(section) {
            return nil
        }
        let details = resultList[section].logs
        if !details.indices.contains(index) {
            return nil
        }
        return details[index]
    }
    
    func search(keyword: String) {
        searchWord = keyword
        if keyword.isEmpty {
            resultList = logs
            searchResult.onNext(resultList.isEmpty)
        } else {
            logDetailDataStore
                .fetch(keyword: keyword, offset: 0, limit: 200)
                .subscribe(onSuccess: { [weak self] details in
                    guard let self = self else { return }
                    self.isLoading.onNext(false)
                    self.isMax = true
                    self.searchLogs = self.groupByCreateDay(details: details)
                    self.resultList = self.searchLogs
                    self.searchResult.onNext(self.resultList.isEmpty)
                },
                onFailure: { [weak self] error in
                    self?.isLoading.onNext(false)
                    self?.errorMessage.onNext(error.message)
                })
                .disposed(by: disposeBag)
        }
    }
    
    func getTag(from name: String) -> Tag? {
        return tagList.filter { $0.name == name }.first
    }
    
    func update(logDetail: LogDetail) {
        if let logSection = self.logs.first(where: { logDetail.isSameSectionTitle(title: $0.dateLabel) }) {
            logSection.update(logDetail: logDetail)
        }
        resultList = logs
        completedGetLogs.onNext(resultList.isEmpty)
    }
    
    func resetOffsetLimit() {
        offset = 0
        isMax = false
    }
    
    private func groupByCreateDay(details: [LogDetail]) -> [LogSection] {
        var logSections: [LogSection] = []
        details.forEach { detail in
            if let logSection = logSections.first(where: { detail.isSameSectionTitle(title: $0.dateLabel) }) {
                logSection.add(log: detail)
            } else {
                let dateLabel = detail.logSectionTitle()
                let logSection = LogSection(dateLabel: dateLabel, detail: detail)
                logSections.append(logSection)
            }
        }
        return logSections
    }
    
    private func addTag(tagNames: Set<String>) {
        let tags = tagNames.compactMap { Tag(name: $0) }.filter { !self.tagList.contains($0) }
        self.tagList += tags
    }
    
    func writeTagLogs(tag: Tag, encoding: EncodingType) {
        let observer = logDetailDataStore.fetch(with: tag, offset: 0, limit: 10000)
        fetch(observer: observer, encoding: encoding)
    }
    
    func writeSearchLogs(keyword: String, encoding: EncodingType) {
        let observer = logDetailDataStore.fetch(keyword: keyword, offset: 0, limit: 10000)
        fetch(observer: observer, encoding: encoding)
    }
    
    private func fetch(observer: Single<[LogDetail]>, encoding: EncodingType) {
        isLoading.onNext(true)
        var text = ExportHelper.shared.createHeaderText()
        observer.subscribe(
            onSuccess: { [weak self] details in
                guard let self = self else { return }
                text += details.compactMap {
                    $0.createFileText()
                }.joined(separator: "\n")
                self.writeFile(text: text, encoding: encoding)
            },
            onFailure: { [weak self] error in
                self?.isLoading.onNext(false)
                self?.errorMessage.onNext(error.message)
            }
        )
        .disposed(by: disposeBag)
    }
    
    private func writeFile(text: String, encoding: EncodingType) {
        let url = ExportHelper.shared.exportUrl() { [weak self] in
            self?.errorMessage.onNext(GeneratorError.failedDeleteOldFile.message)
        }
        print("File Path = \(url.path)")
        do {
            deleteFile(path: url.path)
            try "".write(to: url, atomically: false, encoding: encoding.encoding)
            let fileHandle = try FileHandle(forWritingTo: url)
            var contentData = text.data(using: encoding.encoding, allowLossyConversion: true)!
            if  encoding == .utf8Bom {
                contentData.insert(0xBF, at: 0)
                contentData.insert(0xBB, at: 0)
                contentData.insert(0xEF, at: 0)
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(contentData)
            fileHandle.closeFile()
            completedWrite.onNext(url)
            isLoading.onNext(false)
        } catch {
            isLoading.onNext(false)
            errorMessage.onNext(GeneratorError.failedWrite(error: error).message)
        }
    }
    
    private func deleteFile(path: String) {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path) {
            do {
                try fileManager.removeItem(atPath: path)
            } catch {
                errorMessage.onNext(GeneratorError.failedCreateDirectory.message)
            }
        }
    }
}

class LogSection {
    let dateLabel: String
    let date: Date
    private(set) var logs:[LogDetail] = []
    
    init(dateLabel: String, detail: LogDetail) {
        self.dateLabel = dateLabel
        self.date = detail.createdAt
        self.logs.append(detail)
    }
    
    func add(log: LogDetail) {
        logs.append(log)
    }
    
    func addFirst(log: LogDetail) {
        logs.insert(log, at: 0)
    }
    
    func update(logDetail: LogDetail) {
        if let index = logs.firstIndex(where: { $0.id == logDetail.id }) {
            logs.remove(at: index)
            logs.insert(logDetail, at: index)
        }
    }
    
    func remove(logDetail: LogDetail) {
        if let index = logs.firstIndex(where: { $0.id == logDetail.id }) {
            logs.remove(at: index)
        }
    }
}
