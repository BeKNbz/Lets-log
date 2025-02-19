//
//  TagDataStore.swift
//  LifeLogApp
//
//  Created by ShinUnuma on 2021/07/07.
//

import RxSwift

protocol TagDataStoreType {
    func fetch() -> Single<[Tag]>
    func fetch(offset: Int, limit: Int) -> Single<[Tag]>
}

extension TagDataStoreType {
    func fetch() -> Single<[Tag]> {
        fetch(offset: 0, limit: 50)
    }
}

class TagDataStore: TagDataStoreType, DataStoreError {
    func fetch(offset: Int, limit: Int) -> Single<[Tag]> {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return getError()
        }
        return appDelegate.fetchTags(offset: offset, limit: limit).subscribOnBackground.observeOnMain
    }
    
}
