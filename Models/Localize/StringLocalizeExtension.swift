//
//  StringLocalizeExtension.swift
//  LifeLogApp
//
//  Created by ShinUnuma on 2022/02/05.
//

import Foundation

enum LanguageType: String, CaseIterable {
    case jp
    case en
    case zhCN = "zh-CN"
    case zhTW = "zh-TW"
    
    var title: String {
        switch self {
        case .jp: return "日本語"
        case .en: return "English"
        case .zhCN: return "简体中文"
        case .zhTW: return "繁體中文"
        }
    }
    var locale: String {
        switch self {
        case .jp: return "ja_JP"
        case .en: return "en_US"
        case .zhCN: return "zh_CN"
        case .zhTW: return "zh_TW"
        }
    }
    private static let userDefaultKey: String = "language.type.key"
    
//　currentを用いて、アプリケーションの現在の言語設定を効率的に取得
// （この過程において、UserDefaultsからの設定値を確認）

    private static var _current: LanguageType?
    
    static var current: LanguageType {
        if _current != nil { return _current! }
        if let value = UserDefaults.standard.string(forKey: userDefaultKey),
           let type = LanguageType(rawValue: value) {
            _current = type
            return type
        }
        if let value = Locale.current.regionCode, // 修正: Locale.Current.CountrycCode → Locale.current.regionCode
           let type = LanguageType(rawValue: value) { // 修正: `if let` でカンマを使用
            _current = type
            return type
        }
        _current = .jp
        return .jp
    }
    
    //saveは、LanguageTypeに基づきアプリの状態管理ストア（mainStore）に通知（dispatch)
    //要は、言語設定が変更されるとUserDefaultsに保存→アプリ状態が更新される。
    
    static func save(_ type: LanguageType) {
        _current = type
        let userDefaults = UserDefaults.standard
        userDefaults.set(type.rawValue, forKey: userDefaultKey)
        switch type {
        case .jp: mainStore.dispatch(ChangeLanguageJpAction())
        case .en: mainStore.dispatch(ChangeLanguageEnAction())
        case .zhCN: mainStore.dispatch(ChangeLanguageZhCNAction())
        case .zhTW: mainStore.dispatch(ChangeLanguageZhTWAction())
        }
    }
}

extension String {
    static var localize: StringLocalizable {
        return locaize(LanguageType.current)
    }
    
    static func locaize(_ type: LanguageType) -> StringLocalizable {
        switch type {
        case .jp: return StringJp()
        case .en: return StringEn()
        case .zhCN: return StringZhCN()
        case .zhTW: return StringZhTW()
        }
    }
}

protocol StringLocalizable {
    var menu: LocalizeMenu { get }
    var settings: LocalizeSettings { get }
    var allLog: LocalizeAllLogs { get }
    var logDetail: LocalizeLogDetail { get }
    var changeDate: LocalizeChangeDate { get }
    var editLog: LocalizeEditLog { get }
    var calendar: LocalizeCalendar { get }
    var searchResults: LocalizeSearchResults { get }
    var tags: LocalizeTags { get }
    var dateFormat: LocalizeDateFormat { get }
    var backup: LocalizeBackup { get }
}

protocol LocalizeMenu {
    var title: String { get }
    var calendar: String { get }
    var allLog: String { get }
    var tags: String { get }
    var csvTitle: String { get }
    var csvMessage: String { get }
    var csvExe: String { get }
    var csvCancel: String { get }
    var newLog: String { get }
    var confirm: String { get }
    var close: String { get }
}

protocol LocalizeSettings {
    var title: String { get }
    var selectLanguage: String { get }
    var privacyPolicy: String { get }
    var termOfService: String { get }
    var unicode: String { get }
    var exportRange: String { get }
    var dateRange: String { get }
    var allRange: String { get }
    var rangeMessage: String { get }
    var exportTitle: String { get }
    var importTitle: String { get }
    var aboutUnicodeTitle: String { get }
    var aboutUnicodeMessge: String { get }
    var aboutUtf8BomTitle: String { get }
    var aboutUtf8BomMessage: String { get }
    var aboutUtf8Title: String { get }
    var aboutUtf8Message: String { get }
    var aboutShiftJisTitle: String { get }
    var aboutShiftJisMessage: String { get }
    var aboutBig5Title: String { get }
    var aboutBig5Message: String { get }
    var aboutGB2312Title: String { get }
    var aboutGB2312Message: String { get }
    var outOfRangeMessage: String { get }
    var exportCSV: String { get }
    var exportBackup: String { get }
    var importTypeMessage: String { get }
    var importTitleCustom: String { get }
    var importTitleCsv: String { get }
}

protocol LocalizeAllLogs {
    var title: String { get }
    var dateFormat: String { get }
    var cancel: String { get }
    var search: String { get }
}

protocol LocalizeLogDetail {
    var title: String { get }
    var csvTitle: String { get }
    var csvUtf8Bom: String { get }
    var csvUtf8: String { get }
    var csvShiftJis: String { get }
    var csvBig5: String { get }
    var csvGb2312: String { get }
}

protocol LocalizeChangeDate {
    var title: String { get }
    var done: String { get }
    var formatExample: String { get }
    var weekTitle: String { get }
    var fromDate: String { get }
    var setCurrent: String { get }
}

protocol LocalizeEditLog {
    var title: String { get }
    var emptyLog: String { get }
}

protocol LocalizeCalendar {
    var message: String { get }
    var emptyMessage: String { get }
    var deleteMessage: String { get }
    var delete: String { get }
}

protocol LocalizeSearchResults {
    var message: String { get }
}

protocol LocalizeTags {
    var message: String { get }
}

protocol LocalizeDateFormat {
    var MMddEE: String { get }
    var Md: String { get }
    var yyyyMMddEE: String { get }
    var yyyyMMddEEhhmm: String { get }
    var yyyyMM: String { get }
    var yyyyMMdd: String { get }
    var MM: String { get }
}

protocol LocalizeBackup {
    var loading: String { get }
    var checked: String { get }
    var csvType: String { get }
    var completed: String { get }
    var notFound: String { get }
    var failedRead: String { get }
}
