//
//  EditViewModel.swift
//  LifeLogApp
//
//  Created by ShinUnuma on 2021/07/09.
//

import RxSwift

class EditViewModel {
    let isLoading = PublishSubject<Bool>()
    let errorMessage = PublishSubject<String>()
    let completedWrite = PublishSubject<URL>()
    private(set) var logDetail: LogDetail!
    private let dateHelper = DateHelper.shared
    private(set) var tagList: [Tag] = []
    
    func setup(logDetail: LogDetail, tagList: [Tag]) {
        self.logDetail = logDetail
        self.tagList = tagList
    }
    
    func createDate() -> String {
        guard let logDetail = logDetail else { return "" }
        return dateHelper.convertToString(logDetail.createdAt, format: DateFormat().yyyyMMddEEhhmm)
    }
    
    func writeFile(encoding: EncodingType) {
        guard let logDetail = logDetail else { return }
        isLoading.onNext(true)
        var text = ExportHelper.shared.createHeaderText()
        text += logDetail.createFileText()
        let url = ExportHelper.shared.exportUrl() { [weak self] in
            self?.errorMessage.onNext(GeneratorError.failedDeleteOldFile.message)
        }
        print("File Path = \(url.path)")
        self.deleteFile(path: url.path)
        do {
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
            self.completedWrite.onNext(url)
            self.isLoading.onNext(false)
        } catch {
            self.isLoading.onNext(false)
            self.errorMessage.onNext(GeneratorError.failedWrite(error: error).message)
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
    
    func getTag(from name: String) -> Tag? {
        return tagList.filter { $0.name == name }.first
    }
}
