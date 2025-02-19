//
//  SelectTimeViewModel.swift
//  LifeLogApp
//
//  Created by ShinUnuma on 2021/07/10.
//

import RxSwift

class SelectTimeViewModel {
    private let dateHelper: DateHelper
    private(set) var createDate: Date
    var createDay: String {
        return dateHelper.convertToString(createDate, format: DateFormat().yyyyMMdd)
    }
    
    init(dateHelper: DateHelper = DateHelper.shared) {
        self.dateHelper = dateHelper
        self.createDate = Date()
    }
    
    func setup(createDate: Date) {
        self.createDate = createDate
    }
    
    func timeOnly(date: Date) -> String {
        return dateHelper.convertToString(date, format: DateFormat.timeOnly)
    }
}
