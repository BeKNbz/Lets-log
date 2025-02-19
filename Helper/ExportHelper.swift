//
//  ExportHelper.swift
//  LifeLogApp
//
//  Created by ShinUnuma on 2021/07/14.
//

import Foundation

struct ExportHelper {
    static let shared = ExportHelper()
    
    func createHeaderText() -> String {
        return "identifier,category,date,body,extended body\n"
    }
    
    func exportUrl(errorHandler: (() -> Void)? = nil) -> URL {
        let name = "export_file.csv"
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("lifelog", isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            errorHandler?()
        }
        return directory.appendingPathComponent(name)
    }
}
