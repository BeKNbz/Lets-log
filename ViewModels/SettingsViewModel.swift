//
//  SettingsViewModel.swift
//  LifeLogApp
//
//  Created by ShinUnuma on 2022/01/29.
//

import RxSwift
import Foundation

class SettingsViewModel {
    let reloadTableData = PublishSubject<Void>()
    private let localDataStore: LocalDataStoreType
    private let logDetailDataStore: LogDetailDataStoreType
    private(set) var currentExport = EncodingType.utf8Bom
    private(set) var currentLanguage: LanguageType
    private var importDocumentType: ImportDocumentType = .custom
    
    let isLoading = PublishSubject<Bool>()
    let confirmSave = PublishSubject<Void>()
    let confirmCSVType = PublishSubject<[URL]>()
    let completed = PublishSubject<Void>()
    let failedMessage = PublishSubject<String>()
    private var importUrls: [URL] = []
    private var logDetails: [LogDetail] = []
    
    init(localDataStore: LocalDataStoreType = LocalDataStore(),
         logDetailDataStore: LogDetailDataStoreType = LogDetailDataStore()) {
        self.localDataStore = localDataStore
        self.logDetailDataStore = logDetailDataStore
        currentExport = localDataStore.restoreUniCode() ?? .utf8Bom
        currentLanguage = LanguageType.current
    }
    
    func save(languageType: LanguageType) {
        currentLanguage = languageType
        LanguageType.save(languageType)
        reloadTableData.onNext(())
    }
    
    func update(encodingType: EncodingType) {
        currentExport = encodingType
        reloadTableData.onNext(())
    }
    
    func setup(importType: ImportDocumentType) {
        self.importDocumentType = importType
    }
    
    func importFile(urls: [URL]) {
        self.importUrls = urls
    }
    
    func readFile() {
        logDetails = []
        switch importDocumentType {
        case .custom:
            let customUrls = importUrls.filter { $0.pathExtension == ImportDocumentType.custom.extensionValue }
            if !customUrls.isEmpty {
                readBackupFile(urls: customUrls)
            }
        case .csv:
            let csvUrls = importUrls.filter { $0.pathExtension == ImportDocumentType.csv.extensionValue }
            if !csvUrls.isEmpty {
                confirmCSVType.onNext(csvUrls)
            }
        }
    }
    
    private func readBackupFile(urls: [URL]) {
        let localize = String.localize.backup
        urls.forEach { url in
            do {
                let jsonString = try String(contentsOf: url, encoding: .utf8)
                guard let data = jsonString.data(using: .utf8) else {
                    failedMessage.onNext(localize.failedRead)
                    return
                }
                let details = try JSONDecoder().decode([LogDetail].self, from: data)
                logDetails.append(contentsOf: details)
                if logDetails.isEmpty {
                    failedMessage.onNext(localize.failedRead)
                } else {
                    confirmSave.onNext(())
                }
            } catch {
                dump(error)
                failedMessage.onNext(localize.failedRead)
            }
        }
    }
    
    func readCSVFile(urls: [URL], type: EncodingType) {
        let localize = String.localize.backup
        let splitCount = 4
        urls.forEach { url in
            do {
                let csvString = try String(contentsOf: url, encoding: type.encoding)
                    .replacingOccurrences(of: "identifier,category,date,body,extended body\r\n", with: "")
                    .replacingOccurrences(of: "identifier,category,date,body,extended body\n", with: "")
                let componentList = csvString.components(separatedBy: "\t")
                let detailList = componentList.split(num: splitCount)
                let details: [LogDetail] = detailList.compactMap { contentList in
                    if contentList.count == splitCount {
                        var uuid = contentList[0]
                            .replacingOccurrences(of: "\"\"\r\n", with: "")
                            .replacingOccurrences(of: "\"\"\n", with: "")
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                        uuid = trimUUid(uuid, targets: [-17, -69, -65])
                        let id = UUID(uuidString: uuid) ?? UUID()
                        var tags: Set<String> = []
                        if !contentList[1].isEmpty {
                            let tagList = contentList[1]
                                .components(separatedBy: .newlines)
                                .compactMap { $0.replacingOccurrences(of: "\"", with: "") }
                                .compactMap { $0.isEmpty ? nil : "#\($0)" }
                            tags = Set(tagList)
                        }
                        let createAt = DateHelper.shared.convertToDate(contentList[2], format: DateFormat.export)
                        return LogDetail(
                            id: id,
                            text: contentList[3].replacingOccurrences(of: "\"", with: ""),
                            tags: tags,
                            images: [],
                            createdAt: createAt ?? Date(),
                            updatedAt: nil,
                            createDay: contentList[2],
                            createTime: nil
                        )
                    }
                    return nil
                }
                logDetails.append(contentsOf: details)
                confirmSave.onNext(())
            } catch {
                dump(error)
                failedMessage.onNext(localize.failedRead)
            }
        }
    }
    
    func saveLogDetails() -> Disposable {
        isLoading.onNext(true)
        return logDetailDataStore
            .create(logDetails: logDetails)
            .subscribe(
                onSuccess: { [weak self] in
                    self?.isLoading.onNext(false)
                    self?.completed.onNext(())
                },
                onFailure: { [weak self] error in
                    self?.isLoading.onNext(false)
                    self?.failedMessage.onNext(error.message)
                }
            )
    }
    
    private func trimUUid(_ uuid: String, targets: [Int]) -> String {
        var utf8CString = uuid.utf8CString
        targets.forEach { target in
            if let index = utf8CString.firstIndex(where: { $0 == target }) {
                utf8CString.remove(at: index)
            }
        }
        let result: UnsafeMutableBufferPointer<Int8> = UnsafeMutableBufferPointer<Int8>.allocate(capacity: utf8CString.count)
        _ = result.initialize(from: utf8CString)
        return String(utf8String: result.baseAddress!) ?? ""
    }
}
