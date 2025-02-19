//
//  DataStoreError.swift
//  LifeLogApp
//
//  Created by ShinUnuma on 2021/07/07.
//

import RxSwift

protocol DataStoreError {
    func getError<T>() -> Single<T>
}

extension DataStoreError {
    func getError<T>() -> Single<T> {
        return Single<T>.create { observer -> Disposable in
            observer(.failure(CoreDataError.notFoundAppDelegate))
            return Disposables.create()
        }
    }
}
