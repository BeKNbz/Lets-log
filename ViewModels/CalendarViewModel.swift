//
//  CalendarViewModel.swift
//  LifeLogApp
//
//  Created by ShinUnuma on 2021/07/09.
//

import RxSwift
import SwiftDate

class CalendarViewModel {
    let isLoading = PublishSubject<Bool>()
    let isEnableSave = PublishSubject<Bool>()
    let updateLogList = PublishSubject<Bool>()
    let completedCreate = PublishSubject<Bool>()
    let updateCalendar = PublishSubject<Bool>()
    let isUpdateLogList = PublishSubject<LogDetail?>()
    let errorMessage = PublishSubject<String>()
    let completedDelete = PublishSubject<Bool>()
    let completedWrite = PublishSubject<URL>()
    let completedGetLogs = PublishSubject<Bool>()
    private(set) var logs: [String: [LogDetail]] = [:]
    private(set) var keys: [String] = []
    private(set) var eventDateList: [String] = []
    private(set) var tagList: [Tag] = []
    private(set) var images: Set<String> = []
    private(set) var selectedDate: Date = Date()
    private let dateHelper: DateHelper
    private let logDetailDataStore: LogDetailDataStoreType
    private var dateKey: String
    private var monthDateInfo: (start: Date, end: Date) = (Date(), Date())
    private var isSelectToday = false
    private let disposeBag = DisposeBag()
    var sectionCount: Int {
        return dateKey.isEmpty ? logs.values.count : 1
    }
    var exportDateLabel: String {
        return dateHelper.convertToString(selectedDate, format: DateFormat().yyyyMM)
    }
    var selectedDateLabel: String {
        return dateHelper.convertToString(selectedDate, format: DateFormat().Md)
    }
    var previousMonth: Date {
        return Calendar.current.date(byAdding: .month, value: -1, to: selectedDate)!
    }
    var nextMonth: Date {
        return Calendar.current.date(byAdding: .month, value: +1, to: selectedDate)!
    }
    
    init(logDetailDataStore: LogDetailDataStoreType = LogDetailDataStore(),
         dateHelper: DateHelper = DateHelper.shared) {
        self.logDetailDataStore = logDetailDataStore
        self.dateHelper = dateHelper
        self.dateKey = ""
    }
    
    func setup(tagList: [Tag], isSelectToday: Bool) {
        self.tagList = tagList
        self.isSelectToday = isSelectToday
    }
    
    func fetchLog() {
        isLoading.onNext(true)
        monthDateInfo = dateHelper.getOneMonth(date: selectedDate)
        logDetailDataStore.fetch(start: monthDateInfo.start, end: monthDateInfo.end)
            .subscribe(onSuccess: { [weak self] logDetails in
                guard let `self` = self else { return }
                self.isLoading.onNext(false)
                self.logs = logDetails.reduce(into: [String: [LogDetail]]()) { dictionary, detail in
                    let createDay = detail.calendarSectionTitle()
                    if dictionary[createDay] == nil {
                        dictionary[createDay] = [LogDetail]()
                    }
                    dictionary[createDay]?.append(detail)
                }
                self.keys = self.logs.keys.sorted { a,b in a < b }
                self.eventDateList = logDetails.compactMap { self.dateHelper.convertToString($0.createdAt, format: DateFormat().yyyyMMdd) }
                self.updateCalendar.onNext(self.logs.isEmpty)
                if self.isSelectToday {
                    self.update(selectedDate: Date())
                    self.isSelectToday = false
                }
            },
            onFailure: { [weak self] error in
                self?.isLoading.onNext(false)
                self?.errorMessage.onNext(error.message)
            })
            .disposed(by: disposeBag)
    }
    
    func create(text: String) {
        let tagNames = TagHelper.pickupTags(text: text)
        let createdAt = dateHelper.isToday(selectedDate) ? Date() : selectedDate
        logDetailDataStore.create(text: text, tags: tagNames, images: images, createdAt: createdAt)
            .subscribe(onSuccess: { [weak self] logDetail in
                guard let `self` = self else { return }
                self.addTag(tagNames: tagNames)
                self.isEnableSave.onNext(true)
                let dateFormat = DateFormat()
                let createdDate = self.dateHelper.convertToString(logDetail.createdAt, format: dateFormat.yyyyMM)
                let selectedMonthDate = self.dateHelper.convertToString(self.monthDateInfo.start, format: dateFormat.yyyyMM)
                self.isUpdateLogList.onNext(createdDate == selectedMonthDate ? logDetail : nil)
            },
            onFailure: { [weak self] error in
                self?.isEnableSave.onNext(true)
                self?.errorMessage.onNext(error.message)
            })
            .disposed(by: disposeBag)
    }
    
    func updateLogList(logDetail: LogDetail) {
        var isNewSection = false
        if logs[logDetail.createDay] == nil {
            logs[logDetail.createDay] = [LogDetail]()
            isNewSection = true
        }
        logs[logDetail.createDay]?.insert(logDetail, at: 0)
        keys = logs.keys.sorted { a,b in a < b }
        let eventDate = dateHelper.convertToString(logDetail.createdAt, format: DateFormat().yyyyMMdd)
        eventDateList.append(eventDate)
        completedCreate.onNext(isNewSection)
    }
    
    private func addTag(tagNames: Set<String>) {
        let tags = tagNames.compactMap { Tag(name: $0) }.filter { !self.tagList.contains($0) }
        self.tagList += tags
    }
    
    func delete(indexPath: IndexPath) {
        guard let logDetail = self.logDetail(indexPath: indexPath) else {
            errorMessage.onNext("ログの削除に失敗しました")
            return
        }
        isLoading.onNext(true)
        logDetailDataStore.delete(id: logDetail.id)
            .subscribe(onSuccess: { [weak self] in
                guard let `self` = self else { return }
                self.isLoading.onNext(false)
                guard let index = self.logs[logDetail.createDay]?.firstIndex(where: { $0.id == logDetail.id }) else {
                    return
                }
                self.logs[logDetail.createDay]?.remove(at: index)
                self.completedDelete.onNext(self.logs.isEmpty)
            },
            onFailure: { [weak self] error in
                self?.isLoading.onNext(false)
                self?.errorMessage.onNext(error.message)
            })
            .disposed(by: disposeBag)
    }
    
    func getTag(from name: String) -> Tag? {
        return tagList.filter { $0.name == name }.first
    }
    
    func logDetail(indexPath: IndexPath) -> LogDetail? {
        if dateKey.isEmpty {
            let key = keys[indexPath.section]
            guard let details = logs[key] else { return nil }
            if !details.indices.contains(indexPath.row) { return nil }
            return details[indexPath.row]
        } else {
            guard let list = logs[dateKey] else { return nil }
            if !list.indices.contains(indexPath.row) { return nil }
            return list[indexPath.row]
        }
    }
    
    func update(selectedDate: Date) {
        self.selectedDate = selectedDate
        dateKey = dateHelper.convertToString(selectedDate, format: DateFormat().MMddEE)
        let list = logs[dateKey]
        self.updateLogList.onNext(list?.isEmpty ?? true)
    }
    
    func changedPage(date: Date) {
        self.selectedDate = date
        self.dateKey = ""
        fetchLog()
    }
    
    func eventCount(date: Date) -> Int {
        return eventDateList.filter {
            $0 == dateHelper.convertToString(date, format: DateFormat().yyyyMMdd)
        }.count
    }
    
    func listCount(section: Int) -> Int {
        if dateKey.isEmpty {
            let key = keys[section]
            return logs[key]?.count ?? 0
        } else {
            let key = (keys.filter { $0 == dateKey }).first ?? ""
            return logs[key]?.count ?? 0
        }
    }
    
    func headerTitle(section: Int) -> String {
        return dateKey.isEmpty ? keys[section] : dateKey
    }
    
    func update(logDetail: LogDetail) {
        let result = logs.values.compactMap {
            $0.compactMap { $0.id == logDetail.id ? logDetail : $0 }
        }.joined()
        logs = groupByCreateDay(details: Array(result))
        completedGetLogs.onNext(logs.isEmpty)
    }
    
    private func groupByCreateDay(details: [LogDetail]) -> [String: [LogDetail]] {
        return details.reduce(into: [String: [LogDetail]]()) { dictionary, detail in
            if dictionary[detail.createDay] == nil {
                dictionary[detail.createDay] = [LogDetail]()
            }
            dictionary[detail.createDay]?.append(detail)
        }
    }
    
    func writeCalendarLogs(encoding: EncodingType) {
        if logs.isEmpty { return }
        isLoading.onNext(true)
        var text = ExportHelper.shared.createHeaderText()
        var calendarLogs: [LogDetail] = []
        logs.forEach { key, value in
            calendarLogs += value
        }
        text += calendarLogs.compactMap {
            $0.createFileText()
        }.joined(separator: "\n")
        self.writeFile(text: text, encoding: encoding)
    }
    
    private func writeFile(text: String, encoding: EncodingType) {
        let url = ExportHelper.shared.exportUrl() { [weak self] in
            self?.errorMessage.onNext(GeneratorError.failedDeleteOldFile.message)
        }
        print("File Path = \(url.path)")
        do {
            deleteFile(path: url.path)
            try "".write(to: url, atomically: false, encoding: encoding.encoding)
            let fileHandle = try FileHandle(forWritingTo: url)
            var contentData = text.data(using: encoding.encoding, allowLossyConversion: true)!
            if  encoding == .utf8Bom {
                contentData.insert(0xBF, at: 0)
                contentData.insert(0xBB, at: 0)
                contentData.insert(0xEF, at: 0)
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(contentData)
            fileHandle.closeFile()
            completedWrite.onNext(url)
            isLoading.onNext(false)
        } catch {
            isLoading.onNext(false)
            errorMessage.onNext(GeneratorError.failedWrite(error: error).message)
        }
    }
    
    private func deleteFile(path: String) {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path) {
            do {
                try fileManager.removeItem(atPath: path)
            } catch {
                errorMessage.onNext(GeneratorError.failedCreateDirectory.message)
            }
        }
    }
}
