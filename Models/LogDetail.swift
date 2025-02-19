//
//  LogDetail.swift
//  LifeLogApp
//
//  Created by ShinUnuma on 2021/07/07.
//

import Foundation
import SwiftDate

struct LogDetail: Codable {
    let id: UUID
    let text: String
    let tags: Set<String>
    let images: Set<String>
    let createDay: String
    let createTime: String
    let createdAt: Date
    let updatedAt: Date?
    
    init(id: UUID = UUID(),
         text: String,
         tags: Set<String> = [],
         images: Set<String> = [],
         createdAt: Date = Date(),
         updatedAt: Date? = nil,
         createDay: String? = nil,
         createTime: String? = nil) {
        self.id = id
        self.text = text
        self.tags = tags
        self.images = images
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        let dateHelper = DateHelper.shared
        if let createDay = createDay {
            self.createDay = createDay
        } else {
            self.createDay = dateHelper.convertToString(createdAt, format: DateFormat().MMddEE)
        }
        if let createTime = createTime {
            self.createTime = createTime
        } else {
            self.createTime = dateHelper.convertToString(createdAt, format: DateFormat.timeOnly)
        }
    }

    
    func update(text: String) -> LogDetail {
        return update(text: text, tags: tags, images: images)
    }
    
    func update(text: String, tags: Set<String>) -> LogDetail {
        return update(text: text, tags: tags, images: images)
    }
    
    func update(text: String, tags: Set<String>, images: Set<String>) -> LogDetail {
        return LogDetail(id: self.id,
                         text: text,
                         tags: tags,
                         images: images,
                         createdAt: self.createdAt,
                         updatedAt: Date())
    }

    func update(createDate: Date, createDay: String, createTime: String) -> LogDetail {
        return LogDetail(id: self.id,
                         text: self.text,
                         tags: self.tags,
                         images: self.images,
                         createdAt: createDate,
                         updatedAt: self.updatedAt,
                         createDay: createDay,
                         createTime: createTime)
    }
    
    func logSectionTitle() -> String {
        return DateHelper.shared.convertToString(createdAt, format: DateFormat().yyyyMMddEE)
    }
    
    func calendarSectionTitle() -> String {
        return DateHelper.shared.convertToString(createdAt, format: DateFormat().MMddEE)
    }
    
    func isSameSectionTitle(title: String) -> Bool {
        return createDay == title || DateHelper.shared.convertToString(createdAt, format: DateFormat().yyyyMMddEE) == title
    }
}

extension LogDetail {
    init(entity: LogDetailEntity) throws {
        guard let id = entity.id else { throw ModelError.failedToInitialize() }
        guard let text = entity.text else { throw ModelError.failedToInitialize() }
        guard let tags = entity.tags as? Set<TagEntity> else { throw ModelError.failedToInitialize() }
        guard let images = entity.images as? Set<ImageEntity> else { throw ModelError.failedToInitialize() }
        guard let createdAt = entity.createdAt else { throw ModelError.failedToInitialize() }
        guard let createDay = entity.createDay else { throw ModelError.failedToInitialize() }
        guard let createTime = entity.createTime else { throw ModelError.failedToInitialize() }
        self.id = id
        self.text = text
        self.tags = Set(tags.map { $0.name! })
        self.images = Set(images.map { $0.filePath! })
        self.createdAt = createdAt
        self.updatedAt = entity.updatedAt
        self.createDay = createDay
        self.createTime = createTime
    }
}

extension LogDetailEntity {
    func convertToModel() throws -> LogDetail {
        return try LogDetail(entity: self)
    }
}

extension LogDetail {
    func createFileText() -> String {
        let cellMacCount = 32767
        var firstText = text
        var extendText: String? = nil
        let tagNames = tags.compactMap { $0.replacingOccurrences(of: "#", with: "") }
        if text.count > cellMacCount {
            firstText = String(text.prefix(cellMacCount))
            let index = text.count - cellMacCount
            extendText = String(text.suffix(index))
        }
        return """
        \(id.uuidString),"\(tagNames.joined(separator: "\n"))",\(DateHelper.shared.convertToString(createdAt, format: DateFormat.export)),"\(firstText)","\(extendText ?? "")"
        """
    }
}
