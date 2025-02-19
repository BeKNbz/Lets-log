//
//  UpdateDateViewModel.swift
//  LifeLogApp
//
//  Created by ShinUnuma on 2021/07/09.
//

import RxSwift

class UpdateDateViewModel {
    let isLoading = PublishSubject<Bool>()
    let reload = PublishSubject<Void>()
    let completeUpdate = PublishSubject<LogDetail>()
    let errorMessage = PublishSubject<String>()
    let updateCalendar = PublishSubject<Bool>()
    private(set) var createdDate: Date
    private(set) var createDay: String
    private(set) var createTime: String
    private(set) var currentDate: Date
    private let logDetailDataStore: LogDetailDataStoreType
    private let dateHelper: DateHelper
    private var logDetail: LogDetail?
    private let disposeBag = DisposeBag()
    private(set) var eventDateList: [String] = []
    private var monthDateInfo: (start: Date, end: Date) = (Date(), Date())
    private let dateFormat = DateFormat()
    
    init(logDetailDataStore: LogDetailDataStoreType = LogDetailDataStore(),
        dateHelper: DateHelper = DateHelper.shared) {
        self.logDetailDataStore = logDetailDataStore
        self.dateHelper = dateHelper
        createdDate = Date()
        currentDate = createdDate
        createDay = dateHelper.convertToString(createdDate, format: dateFormat.MMddEE)
        createTime = dateHelper.convertToString(createdDate, format: DateFormat.timeOnly)
    }
    
    func fetchLog() {
        isLoading.onNext(true)
        monthDateInfo = dateHelper.getOneMonth(date: currentDate)
        logDetailDataStore.fetch(start: monthDateInfo.start, end: monthDateInfo.end)
            .subscribe(onSuccess: { [weak self] logDetails in
                guard let self = self else { return }
                self.isLoading.onNext(false)
                self.eventDateList = logDetails.compactMap { $0.createDay }
                self.updateCalendar.onNext(logDetails.isEmpty)
            },
            onFailure: { [weak self] error in
                self?.isLoading.onNext(false)
                self?.errorMessage.onNext(error.message)
            })
            .disposed(by: disposeBag)
    }
    
    func updateLogDetail() {
        guard let logDetail = self.logDetail else { return }
        isLoading.onNext(true)
        let updated = logDetail.update(createDate: createdDate,
                                       createDay: createDay,
                                       createTime: createTime)
        logDetailDataStore.update(updated)
            .subscribe(onSuccess: { [weak self] in
                self?.isLoading.onNext(false)
                self?.completeUpdate.onNext(updated)
            }, onFailure: { [weak self] error in
                self?.isLoading.onNext(false)
                self?.errorMessage.onNext(error.message)
            }).disposed(by: disposeBag)
    }
    
    func setup(logDetail: LogDetail) {
        self.logDetail = logDetail
        createdDate = logDetail.createdAt
        currentDate = createdDate
        createDay = logDetail.createDay
        createTime = logDetail.createTime
    }
    
    func update(createdDate: Date) {
        let updated = dateHelper.updateTime(date: createdDate, time: createTime)
        self.createdDate = updated
        createDay = dateHelper.convertToString(updated, format: dateFormat.MMddEE)
        createTime = dateHelper.convertToString(updated, format: DateFormat.timeOnly)
        reload.onNext(())
    }
    
    func update(createTime: String) {
        let updated = dateHelper.updateTime(date: createdDate, time: createTime)
        createdDate = updated
        createDay = dateHelper.convertToString(updated, format: dateFormat.MMddEE)
        self.createTime = dateHelper.convertToString(updated, format: DateFormat.timeOnly)
        reload.onNext(())
    }
    
    func setNowDate() {
        createdDate = Date()
        createDay = dateHelper.convertToString(createdDate, format: dateFormat.MMddEE)
        createTime = dateHelper.convertToString(createdDate, format: DateFormat.timeOnly)
        reload.onNext(())
    }
    
    func isNoChange() -> Bool {
        guard let logDetail = self.logDetail else {
            return false
        }
        return logDetail.createDay == self.createDay &&
               logDetail.createTime == self.createDay
    }
    
    func changedPage(date: Date) {
        self.currentDate = date
        fetchLog()
    }
    
    func eventCount(date: Date) -> Int {
        let createDay = dateHelper.convertToString(date, format: dateFormat.MMddEE)
        return eventDateList.filter { $0 == createDay }.count
    }
}
