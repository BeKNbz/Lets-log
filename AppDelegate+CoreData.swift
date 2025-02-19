//
//  AppDelegate+CoreData.swift
//  LifeLogApp
//
//  Created by ShinUnuma on 2021/07/07.
//

import RxSwift
import CoreData

extension AppDelegate {
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func save(logDetail: LogDetail) -> Single<LogDetail> {
        return Single.create { [weak self] observer -> Disposable in
            let disposable = Disposables.create()
            guard let self = self else {
                observer(.failure(CoreDataError.failedToSave()))
                return disposable
            }
            let context = self.persistentContainer.viewContext
            let entity = LogDetailEntity(context: context)
            entity.id = logDetail.id
            entity.text = logDetail.text
            entity.createdAt = logDetail.createdAt
            entity.createDay = logDetail.createDay
            entity.createTime = logDetail.createTime
            if let updatedAt = logDetail.updatedAt {
                entity.updatedAt = updatedAt
            }
            do {
                try logDetail.tags.forEach { tag in
                    let request: NSFetchRequest<TagEntity> = TagEntity.fetchRequest()
                    let predicate = NSPredicate(format: "self.name == %@", tag)
                    request.predicate = predicate
                    let result = try context.fetch(request)
                    if let tagEntity = result.first {
                        tagEntity.addToLogs(entity)
                        entity.addToTags(tagEntity)
                    } else {
                        let tagEntity = TagEntity(context: context)
                        tagEntity.name = tag
                        tagEntity.addToLogs(entity)
                        entity.addToTags(tagEntity)
                    }
                }
                logDetail.images.forEach { image in
                    let imageEntity = ImageEntity(context: context)
                    imageEntity.filePath = image
                    imageEntity.addToLogs(entity)
                    entity.addToImages(imageEntity)
                }
                try context.save()
                observer(.success(logDetail))
            } catch {
                observer(.failure(CoreDataError.failedToSave(error: error)))
            }
            return disposable
        }
    }
    
    func save(logDetails: [LogDetail]) -> Single<Void> {
        return Single.create { [weak self] observer -> Disposable in
            let disposable = Disposables.create()
            guard let self = self else {
                observer(.failure(CoreDataError.failedToSave()))
                return disposable
            }
            let context = self.persistentContainer.viewContext
            do {
                for logDetail in logDetails {
                    let request: NSFetchRequest<LogDetailEntity> = LogDetailEntity.fetchRequest()
                    let predicate = NSPredicate(format: "%K == %@", "id", logDetail.id as CVarArg)
                    request.predicate = predicate
                    let result = try context.fetch(request)
                    if result.isEmpty {
                        let entity = LogDetailEntity(context: context)
                        entity.id = logDetail.id
                        entity.text = logDetail.text
                        entity.createdAt = logDetail.createdAt
                        entity.createDay = logDetail.createDay
                        entity.createTime = logDetail.createTime
                        if let updatedAt = logDetail.updatedAt {
                            entity.updatedAt = updatedAt
                        }
                        try logDetail.tags.forEach { tag in
                            let request: NSFetchRequest<TagEntity> = TagEntity.fetchRequest()
                            let predicate = NSPredicate(format: "self.name == %@", tag)
                            request.predicate = predicate
                            let result = try context.fetch(request)
                            if let tagEntity = result.first {
                                tagEntity.addToLogs(entity)
                                entity.addToTags(tagEntity)
                            } else {
                                let tagEntity = TagEntity(context: context)
                                tagEntity.name = tag
                                tagEntity.addToLogs(entity)
                                entity.addToTags(tagEntity)
                            }
                        }
                        logDetail.images.forEach { image in
                            let imageEntity = ImageEntity(context: context)
                            imageEntity.filePath = image
                            imageEntity.addToLogs(entity)
                            entity.addToImages(imageEntity)
                        }
                        try context.save()
                    } else {
                        try result.forEach { entity in
                            entity.setValue(logDetail.id, forKey: "id")
                            entity.setValue(logDetail.text, forKey: "text")
                            entity.setValue(logDetail.createdAt, forKey: "createdAt")
                            entity.setValue(logDetail.createDay, forKey: "createDay")
                            entity.setValue(logDetail.createTime, forKey: "createTime")
                            if let updatedAt = logDetail.updatedAt {
                                entity.setValue(updatedAt, forKey: "updatedAt")
                            }
                            let tagEntities: NSMutableSet = []
                            try logDetail.tags.forEach { tag in
                                let request: NSFetchRequest<TagEntity> = TagEntity.fetchRequest()
                                let predicate = NSPredicate(format: "self.name == %@", tag)
                                request.predicate = predicate
                                let result = try context.fetch(request)
                                if let tagEntity = result.first {
                                    tagEntity.addToLogs(entity)
                                    tagEntities.add(tagEntity)
                                } else {
                                    let tagEntity = TagEntity(context: context)
                                    tagEntity.name = tag
                                    tagEntity.addToLogs(entity)
                                    tagEntities.add(tagEntity)
                                }
                            }
                            entity.setValue(tagEntities, forKey: "tags")
                        }
                        try context.save()
                    }
                }
            } catch {
                observer(.failure(CoreDataError.failedToSave(error: error)))
            }
            observer(.success(()))
            return disposable
        }
    }
    
    func update(logDetail: LogDetail) -> Single<Void> {
        return Single.create { [weak self] observer -> Disposable in
            let disposable = Disposables.create()
            guard let self = self else {
                observer(.failure(CoreDataError.failedToUpdate()))
                return disposable
            }
            let context = self.persistentContainer.viewContext
            do {
                let request: NSFetchRequest<LogDetailEntity> = LogDetailEntity.fetchRequest()
                let predicate = NSPredicate(format: "%K == %@", "id", logDetail.id as CVarArg)
                request.predicate = predicate
                let result = try context.fetch(request)
                try result.forEach { entity in
                    entity.setValue(logDetail.id, forKey: "id")
                    entity.setValue(logDetail.text, forKey: "text")
                    entity.setValue(logDetail.createdAt, forKey: "createdAt")
                    entity.setValue(logDetail.createDay, forKey: "createDay")
                    entity.setValue(logDetail.createTime, forKey: "createTime")
                    if let updatedAt = logDetail.updatedAt {
                        entity.setValue(updatedAt, forKey: "updatedAt")
                    }
                    let tagEntities: NSMutableSet = []
                    try logDetail.tags.forEach { tag in
                        let request: NSFetchRequest<TagEntity> = TagEntity.fetchRequest()
                        let predicate = NSPredicate(format: "self.name == %@", tag)
                        request.predicate = predicate
                        let result = try context.fetch(request)
                        if let tagEntity = result.first {
                            tagEntity.addToLogs(entity)
                            tagEntities.add(tagEntity)
                        } else {
                            let tagEntity = TagEntity(context: context)
                            tagEntity.name = tag
                            tagEntity.addToLogs(entity)
                            tagEntities.add(tagEntity)
                        }
                    }
                    dump(tagEntities)
                    entity.setValue(tagEntities, forKey: "tags")
                }
                try context.save()
                observer(.success(()))
            } catch {
                observer(.failure(CoreDataError.failedToUpdate(error: error)))
            }
            return disposable
        }
    }
    
    func fetchLogsAll(offset: Int, limit: Int) -> Single<[LogDetail]> {
        return fetch(offset: offset, limit: limit)
    }
    
    func fetchLogs(with tag: Tag, offset: Int, limit: Int) -> Single<[LogDetail]> {
        let predicate = NSPredicate(format: "ANY tags.name == %@", tag.name)
        return fetch(offset: offset, limit: limit, predicate: predicate)
    }
    
    func fetchLogs(start: Date, end: Date, offset: Int, limit: Int) -> Single<[LogDetail]> {
        //print(DateHelper.shared.convertToString(start, format: .jpyyyyMMddEEhhmm))
        //print(DateHelper.shared.convertToString(end, format: .jpyyyyMMddEEhhmm))
        let predicate = NSPredicate(format: "self.createdAt BETWEEN {%@ , %@}", start as NSDate, end as NSDate)
        return fetch(offset: offset, limit: limit, predicate: predicate)
    }
    
    func fetchLogs(keyword: String, offset: Int, limit: Int) -> Single<[LogDetail]> {
        let text = NSPredicate(format: "self.text CONTAINS %@", keyword)
        let tags = NSPredicate(format: "ANY tags.name CONTAINS %@", keyword)
        let createDay = NSPredicate(format: "self.createDay CONTAINS %@", keyword)
        let createTime = NSPredicate(format: "self.createTime CONTAINS %@", keyword)
        let predicate = NSCompoundPredicate(type: .or, subpredicates: [text, tags, createDay, createTime])
        return fetch(offset: offset, limit: limit, predicate: predicate)
    }
    
    private func fetch(offset: Int, limit: Int, predicate: NSPredicate? = nil) -> Single<[LogDetail]> {
        return Single.create { [weak self] observer -> Disposable in
            let disposable = Disposables.create()
            guard let self = self else {
                observer(.failure(CoreDataError.failedToFetch()))
                return disposable
            }
            let context = self.persistentContainer.viewContext
            do {
                let request: NSFetchRequest<LogDetailEntity> = LogDetailEntity.fetchRequest()
                if let predicate = predicate {
                    request.predicate = predicate
                }
                request.fetchOffset = offset
                request.fetchLimit = limit
                request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
                let logDetails = try context.fetch(request).compactMap { try $0.convertToModel() }
                observer(.success(logDetails))
            } catch {
                observer(.failure(CoreDataError.failedToFetch(error: error)))
            }
            return disposable
        }
    }
    
    func fetchTags(offset: Int, limit: Int) -> Single<[Tag]> {
        return Single.create { [weak self] observer -> Disposable in
            let disposable = Disposables.create()
            guard let self = self else {
                observer(.failure(CoreDataError.failedToFetch()))
                return disposable
            }
            let context = self.persistentContainer.viewContext
            do {
                let request: NSFetchRequest<TagEntity> = TagEntity.fetchRequest()
                request.fetchOffset = offset
                request.fetchLimit = limit
                let tags = try context.fetch(request).compactMap { try $0.convertToModel() }
                observer(.success(tags))
            } catch {
                observer(.failure(CoreDataError.failedToFetch(error: error)))
            }
            return disposable
        }
    }
    
    func fetchLogCountAll() -> Single<Int> {
        return fetchCountAll()
    }
    
    func fetchLogCount(with tag: Tag) -> Single<TagInfo> {
        let predicate = NSPredicate(format: "ANY tags.name == %@", tag.name)
        return fetchLogCount(predicate: predicate, tag: tag)
    }
    
    func delete(id: UUID) -> Single<Void> {
        return Single.create { [weak self] observer -> Disposable in
            let disposable = Disposables.create()
            guard let self = self else {
                observer(.failure(CoreDataError.failedToDelete()))
                return disposable
            }
            let context = self.persistentContainer.viewContext
            do {
                let request: NSFetchRequest<LogDetailEntity> = LogDetailEntity.fetchRequest()
                let predicate = NSPredicate(format: "%K == %@", "id", id as CVarArg)
                request.predicate = predicate
                let result = try context.fetch(request)
                result.forEach { context.delete($0) }
                try context.save()
                observer(.success(()))
            } catch {
                observer(.failure(CoreDataError.failedToDelete(error: error)))
            }
            return disposable
        }
    }
    
    private func fetchCountAll() -> Single<Int> {
        return Single.create { [weak self] observer -> Disposable in
            let disposable = Disposables.create()
            guard let self = self else {
                observer(.failure(CoreDataError.failedToFetch()))
                return disposable
            }
            let context = self.persistentContainer.viewContext
            let request: NSFetchRequest<LogDetailEntity> = LogDetailEntity.fetchRequest()
            request.includesSubentities = false
            do {
                let count = try context.count(for: request)
                observer(.success(count))
            } catch {
                observer(.failure(CoreDataError.failedToFetch(error: error)))
            }
            return disposable
        }
    }
    
    private func fetchLogCount(predicate: NSPredicate, tag: Tag) -> Single<TagInfo> {
        return Single.create { [weak self] observer -> Disposable in
            let disposable = Disposables.create()
            guard let self = self else {
                observer(.failure(CoreDataError.failedToFetch()))
                return disposable
            }
            let context = self.persistentContainer.viewContext
            let request: NSFetchRequest<LogDetailEntity> = LogDetailEntity.fetchRequest()
            request.includesSubentities = false
            request.predicate = predicate
            do {
                let count = try context.count(for: request)
                if count == 0 {
                    let tagRequest: NSFetchRequest<TagEntity> = TagEntity.fetchRequest()
                    tagRequest.predicate = NSPredicate(format: "self.name == %@", tag.name)
                    let result = try context.fetch(tagRequest)
                    result.forEach { context.delete($0) }
                    try context.save()
                }
                observer(.success(TagInfo(tag: tag, count: count)))
            } catch {
                observer(.failure(CoreDataError.failedToFetch(error: error)))
            }
            return disposable
        }
    }
}
