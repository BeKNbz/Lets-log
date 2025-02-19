//
//  MainViewModel.swift
//  LifeLogApp
//
//  Created by ShinUnuma on 2021/07/06.
//

import RxSwift

class MainViewModel {
    let isLoading = PublishSubject<Bool>()
    let reloadData = PublishSubject<Void>()
    let isEnableSave = PublishSubject<Bool>()
    let completeCreated = PublishSubject<Void>()
    private(set) var images: Set<String> = []
    let errorMessage = PublishSubject<String>()
    let completedWrite = PublishSubject<URL>()
    private let logDetailDataStore: LogDetailDataStoreType
    private let tagDataStore: TagDataStoreType
    private let dateHelper: DateHelper
    private let disposeBag = DisposeBag()
    private(set) var logCount: Int = 0
    private(set) var tags: [TagInfo] = []
    var tagCount: Int {
        return tags.count
    }
    var tagList: [Tag] {
        return tags.compactMap { $0.tag }
    }
    
    init(logDetailDataStore: LogDetailDataStoreType = LogDetailDataStore(),
         tagDataStore: TagDataStoreType = TagDataStore(),
         dateHelper: DateHelper = DateHelper.shared) {
        self.logDetailDataStore = logDetailDataStore
        self.tagDataStore = tagDataStore
        self.dateHelper = dateHelper
    }
    
    func create(text: String) {
        isLoading.onNext(true)
        let tagNames = TagHelper.pickupTags(text: text)
        logDetailDataStore.create(text: text, tags: tagNames, images: images)
            .subscribe(onSuccess: { [weak self] logDetail in
                self?.isLoading.onNext(false)
                guard let `self` = self else { return }
                self.isEnableSave.onNext(true)
                self.fetchAll()
                self.completeCreated.onNext(())
            },
            onFailure: { [weak self] error in
                self?.isLoading.onNext(false)
                self?.isEnableSave.onNext(true)
                self?.errorMessage.onNext(error.message)
            })
            .disposed(by: disposeBag)
    }
    
    func fetchAll() {
        isLoading.onNext(true)
        Observable.zip(
            logDetailDataStore.fetchCount().asObservable(),
            tagDataStore.fetch().asObservable()
        )
        .subscribe(onNext: { [weak self] logCount, tags in
            self?.logCount = logCount
            if tags.isEmpty {
                self?.reloadData.onNext(())
            } else {
                self?.fetchTagCount(tags: tags)
            }
        }, onError: { error in
            print("\(error.message)")
        }, onCompleted: { [weak self] in
            self?.isLoading.onNext(false)
        })
        .disposed(by: disposeBag)
    }
    
    private func fetchTagCount(tags: [Tag]) {
        let observables: [Observable<TagInfo>] = tags.compactMap {
            self.logDetailDataStore.fetchCount(with: $0).asObservable()
        }
        return Observable.zip(observables)
            .subscribe(onNext: { [weak self] tagInfoList in
                guard let self = self else { return }
                self.tags = tagInfoList.filter { $0.count > 0 }
                self.reloadData.onNext(())
            }, onError: { error in
                print("\(error.message)")
            }).disposed(by: disposeBag)
    }
    
    func tagInfo(index: Int) -> TagInfo? {
        if !tags.indices.contains(index) {
            return nil
        }
        return tags[index]
    }
    
    func writeAllLogs(encoding: EncodingType) {
        isLoading.onNext(true)
        var text = ExportHelper.shared.createHeaderText()
        logDetailDataStore.fetchAll().subscribe(
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
        ).disposed(by: disposeBag)
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
            if encoding == .utf8Bom {
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

struct TagInfo {
    let tag: Tag
    let count: Int
}
