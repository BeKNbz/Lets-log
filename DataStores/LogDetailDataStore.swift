//
//  LogDetailDataStore.swift
//  LifeLogApp
//
//  Created by ShinUnuma on 2021/07/07.
//

import RxSwift

protocol LogDetailDataStoreType {
    func create(text: String, tags: Set<String>, images: Set<String>, createdAt: Date) -> Single<LogDetail>
    func create(logDetails: [LogDetail]) -> Single<Void>
    func update(_ logDetail: LogDetail) -> Single<Void>
    func fetchAll() -> Single<[LogDetail]>
    func fetchAll(offset: Int, limit: Int) -> Single<[LogDetail]>
    func fetch(with tag: Tag) -> Single<[LogDetail]>
    func fetch(with tag: Tag, offset: Int, limit: Int) -> Single<[LogDetail]>
    func fetch(start: Date, end: Date) -> Single<[LogDetail]>
    func fetch(start: Date, end: Date, offset: Int, limit: Int) -> Single<[LogDetail]>
    func fetch(keyword: String, offset: Int, limit: Int) -> Single<[LogDetail]>
    func fetchCount() -> Single<Int>
    func fetchCount(with tag: Tag) -> Single<TagInfo>
    func delete(id: UUID) -> Single<Void>
}

extension LogDetailDataStoreType {
    func create(text: String, tags: Set<String>, images: Set<String>, createdAt: Date = Date()) -> Single<LogDetail> {
        create(text: text, tags: tags, images: images, createdAt: createdAt)
    }
    
    func fetchAll() -> Single<[LogDetail]> {
        fetchAll(offset: 0, limit: 99999)
    }
    
    func fetch(start: Date, end: Date) -> Single<[LogDetail]> {
        fetch(start: start, end: end, offset: 0, limit: 99999)
    }
    
    func fetch(with tag: Tag) -> Single<[LogDetail]> {
        fetch(with: tag, offset: 0, limit: 50)
    }
}

struct LogDetailDataStore: LogDetailDataStoreType, DataStoreError {
    func create(text: String, tags: Set<String>, images: Set<String>, createdAt: Date) -> Single<LogDetail> {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return getError()
        }
        let logDetail = LogDetail(text: text, tags: tags, images: images, createdAt: createdAt)
        return appDelegate.save(logDetail: logDetail).subscribOnBackground.observeOnMain
    }
    
    func create(logDetails: [LogDetail]) -> Single<Void> {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return getError()
        }
        return appDelegate.save(logDetails: logDetails)
    }
    
    func update(_ logDetail: LogDetail) -> Single<Void> {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return getError()
        }
        return appDelegate.update(logDetail: logDetail).subscribOnBackground.observeOnMain
    }
    
    func fetchAll(offset: Int, limit: Int) -> Single<[LogDetail]> {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return getError()
        }
        return appDelegate.fetchLogsAll(offset: offset, limit: limit).subscribOnBackground.observeOnMain
    }
    
    func fetch(with tag: Tag, offset: Int, limit: Int) -> Single<[LogDetail]> {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return getError()
        }
        return appDelegate.fetchLogs(with: tag, offset: offset, limit: limit).subscribOnBackground.observeOnMain
    }
    
    func fetch(start: Date, end: Date, offset: Int, limit: Int) -> Single<[LogDetail]> {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return getError()
        }
        return appDelegate.fetchLogs(start: start, end: end, offset: offset, limit: limit).subscribOnBackground.observeOnMain
    }
    
    func fetch(keyword: String, offset: Int, limit: Int) -> Single<[LogDetail]> {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return getError()
        }
        return appDelegate.fetchLogs(keyword: keyword, offset: offset, limit: limit).subscribOnBackground.observeOnMain
    }
    
    func fetchCount() -> Single<Int> {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return getError()
        }
        return appDelegate.fetchLogCountAll().subscribOnBackground.observeOnMain
    }
    
    func fetchCount(with tag: Tag) -> Single<TagInfo> {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return getError()
        }
        return appDelegate.fetchLogCount(with: tag).subscribOnBackground.observeOnMain
    }
    
    func delete(id: UUID) -> Single<Void> {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return getError()
        }
        return appDelegate.delete(id: id).subscribOnBackground.observeOnMain
    }
}
