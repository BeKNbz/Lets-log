//
//  Tag.swift
//  LifeLogApp
//
//  Created by ShinUnuma on 2021/07/07.
//

import Foundation

struct Tag: Hashable, Equatable {
    let name: String
    
    static func == (lhs: Tag, rhs: Tag) -> Bool {
        return lhs.name == rhs.name
    }
}

extension Tag {
    init(entity: TagEntity) throws {
        guard let name = entity.name else { throw ModelError.failedToInitialize() }
        self.name = name
    }
}

extension TagEntity {
    func convertToModel() throws -> Tag {
        return try Tag(entity: self)
    }
}
