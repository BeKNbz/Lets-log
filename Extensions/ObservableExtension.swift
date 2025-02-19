//
//  ObservableExtension.swift
//  LifeLogApp
//
//  Created by ShinUnuma on 2021/07/07.
//

import RxSwift

extension ObservableType {
    var main: Observable<Element> {
        return self.observe(on: MainScheduler.instance)
    }
}

extension PrimitiveSequence {
    var observeOnMain: PrimitiveSequence<Trait, Element> {
        return self.observe(on: MainScheduler.instance)
    }
    var subscribOnBackground: PrimitiveSequence<Trait, Element> {
        return self.subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
    }
}
