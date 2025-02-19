//
//  AppError.swift
//  LifeLogApp
//
//  Created by ShinUnuma on 2021/07/07.
//

import Foundation

extension Error {
    var message: String {
        switch self {
        case let error as CoreDataError:
            return error.message
        case let error as ModelError:
            return error.message
        case let error as GeneratorError:
            return error.message
        default:
            return localizedDescription
        }
    }
    
    internal func getMessage(message: String, error: Error?) -> String {
        if let error = error {
            return message + " " + error.localizedDescription
        }
        return message
    }
}

enum CoreDataError: Error {
    case failedToSave(error: Error? = nil)
    case failedToUpdate(error: Error? = nil)
    case failedToDelete(error: Error? = nil)
    case failedToFetch(error: Error? = nil)
    case notFoundData(error: Error? = nil)
    case notFoundAppDelegate
    
    var message: String {
        switch self {
        case .failedToSave(let error):
            return getMessage(message: "Failed to save.", error: error)
        case .failedToUpdate(let error):
            return getMessage(message: "Update failed.", error: error)
        case .failedToDelete(let error):
            return getMessage(message: "Failed to delete.", error: error)
        case .failedToFetch(let error):
            return getMessage(message: "Failed to get.", error: error)
        case .notFoundData(let error):
            return getMessage(message: "Not found entity", error: error)
        case .notFoundAppDelegate:
            return getMessage(message: "Not found app delegate", error: nil)
        }
    }
}

enum ModelError: Error {
    case failedToInitialize(error: Error? = nil)
    
    var message: String {
        switch self {
        case .failedToInitialize(let error):
            return getMessage(message: "Failed to initalize", error: error)
        }
    }
}

enum GeneratorError: Error {
    case failedCreateDirectory
    case failedWrite(error: Error? = nil)
    case failedDeleteOldFile
    case unknown
    
    var message: String {
        switch self {
        case .failedCreateDirectory:
            return "failed to create text directory"
        case .failedWrite(let error):
            return getMessage(message: "failed to write text file", error: error)
        case .failedDeleteOldFile:
            return "failed to delete old file"
        case .unknown:
            return "GeneratorError unkown error"
        }
    }
}
