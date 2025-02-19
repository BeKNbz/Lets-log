//
//  UpdateTextViewModel.swift
//  LifeLogApp
//
//  Created by ShinUnuma on 2021/07/09.
//

import RxSwift

class UpdateTextViewModel {
    let isLoading = PublishSubject<Bool>()
    let completedUpdated = PublishSubject<LogDetail>()
    let isEmptyTags = PublishSubject<Bool>()
    let errorMessage = PublishSubject<String>()
    private var logDetail: LogDetail?
    private let logDetailDataStore: LogDetailDataStoreType
    private let tagDataStore: TagDataStoreType
    private let disposeBag = DisposeBag()
    private(set) var tags: [Tag] = []
    var text: String {
        return logDetail?.text ?? ""
    }
    
    init(logDetailDataStore: LogDetailDataStoreType = LogDetailDataStore(),
         tagDataStore: TagDataStoreType = TagDataStore()) {
        self.logDetailDataStore = logDetailDataStore
        self.tagDataStore = tagDataStore
    }
    
    func setup(logDetail: LogDetail) {
        self.logDetail = logDetail
    }
    
    func fetchTags() {
        isLoading.onNext(true)
        tagDataStore.fetch()
            .subscribe(onSuccess: { [weak self] tags in
                self?.isLoading.onNext(false)
                self?.tags = tags
                
            },
            onFailure: { [weak self] error in
                self?.isLoading.onNext(false)
                self?.errorMessage.onNext(error.message)
            })
            .disposed(by: disposeBag)
    }
    
    func update(text: String) {
        guard let logDetail = self.logDetail else { return }
        let tags = TagHelper.pickupTags(text: text)
        let updated = logDetail.update(text: text, tags: tags)
        isLoading.onNext(true)
        logDetailDataStore.update(updated)
            .subscribe(onSuccess: { [weak self] in
                self?.isLoading.onNext(false)
                self?.completedUpdated.onNext(updated)
            },
            onFailure: { [weak self] error in
                self?.isLoading.onNext(false)
                self?.errorMessage.onNext(error.message)
            })
            .disposed(by: disposeBag)
    }
    
    func isChange(text: String) -> Bool {
        guard let logDetail = self.logDetail else {
            return false
        }
        return logDetail.text != text
    }
}
