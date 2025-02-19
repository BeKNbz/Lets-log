//
//  ExportViewModel.swift
//  LifeLogApp
//
//  Created by ShinUnuma on 2021/07/13.
//

import RxSwift
import Security

class ExportViewModel {
    let isLoading = PublishSubject<Bool>()
    let completedExport = PublishSubject<URL>()
    let resultCountZero = PublishSubject<Void>()
    let setupEncodingType = PublishSubject<EncodingType>()
    let setupRangeType = PublishSubject<RangeType>()
    let setupRangeDate = PublishSubject<(start: Date, end: Date)>()
    let errorMessage = PublishSubject<String>()
    private let logDetailDataStore: LogDetailDataStoreType
    private let localDataStore: LocalDataStoreType
    private let dateHelper: DateHelper
    private(set) var encodingType: EncodingType = .utf8Bom
    private(set) var rangeType: RangeType = .date
    private(set) var startDate: Date = Date()
    private(set) var endDate: Date = Date()
    private let disposeBag = DisposeBag()
    var initStartAndEnd: (start: Date, end: Date) {
        return dateHelper.getOneMonth()
    }
    
    init(logDetailDataStore: LogDetailDataStoreType = LogDetailDataStore(),
         localDataStore: LocalDataStoreType = LocalDataStore(),
         dateHelper: DateHelper = DateHelper.shared) {
        self.logDetailDataStore = logDetailDataStore
        self.localDataStore = localDataStore
        self.dateHelper = dateHelper
    }
    
    func setup() {
        if let value = localDataStore.restoreUniCode() {
            encodingType = value
            setupEncodingType.onNext(value)
        }
        if let value = localDataStore.restoreRange() {
            setupRangeType.onNext(value)
        }
        if let start = localDataStore.restoreStartDate(), let end = localDataStore.restoreEndDate() {
            setupRangeDate.onNext((start: start, end: end))
        }
    }
    
    func update(encodingType: EncodingType) {
        self.encodingType = encodingType
        localDataStore.storeUniCode(type: encodingType)
        setupEncodingType.onNext(encodingType)
    }
    
    func update(rangeType: RangeType) {
        self.rangeType = rangeType
        localDataStore.storeRange(type: rangeType)
    }
    
    func update(start: Date, end: Date) {
        startDate = start
        endDate = end
    }
    
    func update(start: Date) {
        localDataStore.storeStart(date: start)
    }
    
    func update(end: Date) {
        localDataStore.storeEnd(date: end)
    }
    
    func exportCSVFile() -> Disposable {
        switch rangeType {
        case .date:
            return writeLogs(start: startDate, end: endDate)
        case .all:
            return writeAllLogs()
        }
    }
    
    private func writeLogs(start: Date, end: Date) -> Disposable {
        isLoading.onNext(true)
        var text = ExportHelper.shared.createHeaderText()
        return logDetailDataStore.fetch(start: start, end: end).subscribe(
            onSuccess: { [weak self] details in
                guard let `self` = self else { return }
                if details.isEmpty {
                    self.isLoading.onNext(false)
                    self.resultCountZero.onNext(())
                    return
                }
                text += details.compactMap {
                    $0.createFileText()
                }.joined(separator: "\n")
                self.writeFile(text: text)
            },
            onFailure: { [weak self] error in
                self?.isLoading.onNext(false)
                self?.errorMessage.onNext(error.message)
            }
        )
    }
    
    private func writeAllLogs() -> Disposable {
        isLoading.onNext(true)
        var text = ExportHelper.shared.createHeaderText()
        return logDetailDataStore.fetchAll().subscribe(
            onSuccess: { [weak self] details in
                guard let `self` = self else { return }
                if details.isEmpty {
                    self.isLoading.onNext(false)
                    self.resultCountZero.onNext(())
                    return
                }
                text += details.compactMap {
                    $0.createFileText()
                }.joined(separator: "\n")
                self.writeFile(text: text)
            },
            onFailure: { [weak self] error in
                self?.isLoading.onNext(false)
                self?.errorMessage.onNext(error.message)
            }
        )
    }
    
    private func writeFile(text: String) {
        let url = ExportHelper.shared.exportUrl() { [weak self] in
            self?.isLoading.onNext(false)
            self?.errorMessage.onNext(GeneratorError.failedDeleteOldFile.message)
            return
        }
        do {
            deleteFile(path: url.path)
            if var contentData = text.data(using: encodingType.encoding, allowLossyConversion: true) {
                try "".write(to: url, atomically: false, encoding: encodingType.encoding)
                let fileHandle = try FileHandle(forWritingTo: url)
                if encodingType == .utf8Bom {
                    contentData.insert(0xBF, at: 0)
                    contentData.insert(0xBB, at: 0)
                    contentData.insert(0xEF, at: 0)
                }
                fileHandle.seekToEndOfFile()
                fileHandle.write(contentData)
                fileHandle.closeFile()
            } else {
                try "".write(to: url, atomically: false, encoding: encodingType.encoding)
                let contentData = text.data(using: .utf8, allowLossyConversion: true)!
                let fileHandle = try FileHandle(forWritingTo: url)
                fileHandle.seekToEndOfFile()
                fileHandle.write(contentData)
                fileHandle.closeFile()
            }
            self.completedExport.onNext(url)
            self.isLoading.onNext(false)
        } catch {
            self.isLoading.onNext(false)
            self.errorMessage.onNext(GeneratorError.failedWrite(error: error).message)
        }
    }
    
    func exportBackupFile() -> Disposable {
        isLoading.onNext(true)
        return logDetailDataStore.fetchAll().subscribe(
            onSuccess: { [weak self] details in
                guard let `self` = self else { return }
                self.isLoading.onNext(false)
                let url = self.exportUrl()
                print("Backup File Path = \(url.path)")
                self.deleteFile(path: url.path)
                do {
                    let jsonString = try self.toJsonString(logDetails: details)
                    try jsonString?.write(to: url, atomically: false, encoding: .utf8)
                    self.completedExport.onNext(url)
                } catch {
                    self.errorMessage.onNext(ExportError.failedWrite.message)
                }
            },
            onFailure: { [weak self] error in
                self?.isLoading.onNext(false)
                self?.errorMessage.onNext(error.message)
            }
        )
    }
    
    private func toJsonString(logDetails: [LogDetail]) throws -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(logDetails)
        return String(data: data, encoding: .utf8)
    }
    
    private func exportUrl() -> URL {
        let name = "backup_file.letslog"
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("letslog", isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            errorMessage.onNext(GeneratorError.failedDeleteOldFile.message)
        }
        return directory.appendingPathComponent(name)
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

enum RangeType: Int {
    case date
    case all
}

enum ExportFileType: Int, CaseIterable {
    case csv
    case backup
    
    var title: String {
        switch self {
        case .csv: return String.localize.settings.exportCSV
        case .backup: return String.localize.settings.exportBackup
        }
    }
}
