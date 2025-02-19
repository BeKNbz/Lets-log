//
//  Backup.swift
//  LifeLogApp
//
//  Created by ShinUnuma on 2022/02/09.
//

import Foundation
import RxSwift

class Backup {
    let completed = PublishSubject<URL>()
    let failedMessage = PublishSubject<String>()
    private let logDetails: [LogDetail]
    
    init(logDetails: [LogDetail]) {
        self.logDetails = logDetails
    }
    
    private func deleteFile(path: String) {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path) {
            do {
                try fileManager.removeItem(atPath: path)
            } catch {
                failedMessage.onNext(GeneratorError.failedCreateDirectory.message)
            }
        }
    }
}

enum ExportError: Error {
    case failedCreateDirectory
    case failedWrite
    case failedDeleteOldFile
    case unknown
    
    var message: String {
        switch self {
        case .failedCreateDirectory:
            return "failed to create teapot directory"
        case .failedWrite:
            return "failed to write teapot file"
        case .failedDeleteOldFile:
            return "failed to delete old file"
        case .unknown:
            return "GeneratorError unkown error"
        }
    }
}
