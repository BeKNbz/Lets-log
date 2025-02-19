//
//  DateHelper.swift
//  LifeLogApp
//
//  Created by ShinUnuma on 2021/07/08.
//

import Foundation

enum DateLocale: String {
    case en_US_POSIX = "en_US_POSIX"
    case ja_JP = "ja_JP"
}

enum DateTimeZone: String {
    case jst = "JST"
    case tokyo = "Asia/Tokyo"
}

struct DateFormat {
    var MMddEE: String { String.localize.dateFormat.MMddEE }
    var Md: String { String.localize.dateFormat.Md }
    var yyyyMMddEE: String { String.localize.dateFormat.yyyyMMddEE }
    var yyyyMMddEEhhmm: String { String.localize.dateFormat.yyyyMMddEEhhmm }
    var yyyyMM: String { String.localize.dateFormat.yyyyMM }
    var yyyyMMdd: String { String.localize.dateFormat.yyyyMMdd }
    var MM: String { String.localize.dateFormat.MM }
    static let export = "MM/dd/yyyy HH:mm:ss"
    static let timeOnly = "HH:mm"
}

extension Date {
    func fixed(year: Int? = nil, month: Int? = nil, day: Int? = nil, hour: Int? = nil, minute: Int? = nil, second: Int? = nil) -> Date {
        var calendar = self.calendar
        calendar.locale = Locale(identifier: LanguageType.current.locale)
        var comp = DateComponents()
        comp.year   = year   ?? calendar.component(.year,   from: self)
        comp.month  = month  ?? calendar.component(.month,  from: self)
        comp.day    = day    ?? calendar.component(.day,    from: self)
        comp.hour   = hour   ?? calendar.component(.hour,   from: self)
        comp.minute = minute ?? calendar.component(.minute, from: self)
        comp.second = second ?? calendar.component(.second, from: self)
        return calendar.date(from: comp)!
    }
    
    var zeroclock: Date {
        return fixed(hour: 0, minute: 0, second: 0)
    }
}

class DateHelper {
    static let shared = DateHelper()
    let dateFormatter: DateFormatter
    private(set) var calendar: Calendar
    
    init() {
        dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: LanguageType.current.locale)
        dateFormatter.timeZone = .current
        calendar = Calendar.current
        calendar.timeZone = .current
    }
    
    func convertToString(_ date: Date, format: String) -> String {
        dateFormatter.locale = Locale(identifier: LanguageType.current.locale)
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
    
    func convertToDate(_ dateString: String, format: String) -> Date? {
        dateFormatter.locale = Locale(identifier: LanguageType.current.locale)
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: dateString)
    }

    func getOneMonth(date: Date = Date()) -> (start: Date, end: Date) {
        calendar.locale = Locale(identifier: LanguageType.current.locale)
        var component = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        component.day = 1
        component.hour = 0
        component.minute = 0
        component.second = 0
        let start = calendar.date(from: component)!
        let add = calendar.date(byAdding: .month, value: 1, to: start)!
        let end = calendar.date(byAdding: .second, value: -1, to: add)!
        return (start: start, end: end)
    }
    
    func isToday(_ value: Date) -> Bool {
        calendar.locale = Locale(identifier: LanguageType.current.locale)
        let today = calendar.dateComponents([.year, .month, .day], from: Date())
        let target = calendar.dateComponents([.year, .month, .day], from: value)
        return target.year != nil && target.month != nil && target.day != nil
        && today.year == target.year && today.month == target.month && today.day == target.day
    }
    
    func updateTime(date: Date, time: String) -> Date {
        calendar.locale = Locale(identifier: LanguageType.current.locale)
        var dateComponent = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        dateFormatter.locale = Locale(identifier: LanguageType.current.locale)
        dateFormatter.dateFormat = DateFormat.timeOnly
        let timeComponent = calendar.dateComponents([.hour, .minute, .second], from: dateFormatter.date(from: time)!)
        dateComponent.hour = timeComponent.hour
        dateComponent.minute = timeComponent.minute
        dateComponent.second = 0
        return calendar.date(from: dateComponent)!
         
    }
}
