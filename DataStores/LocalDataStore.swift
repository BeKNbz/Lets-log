//
//  LocalDataStore.swift
//  LifeLogApp
//
//  Created by ShinUnuma on 2021/10/07.
//
//　By using LocalDataStore class, defining methods to store and restore data in "UserDefaults"

import RxSwift

//プロトコルの定義。次の一式を実施（コード、範囲、開始日と終了日、言語の保存と復元）

protocol LocalDataStoreType {
    func storeUniCode(type: EncodingType)
    func restoreUniCode() -> EncodingType?
    func storeRange(type: RangeType)
    func restoreRange() -> RangeType?
    func storeStart(date: Date)
    func restoreStartDate() -> Date?
    func storeEnd(date: Date)
    func restoreEndDate() -> Date?
    func storeLanguage(type: LanguageType)
    func restoreLanguage() -> LanguageType?
}

//クラスの定義

class LocalDataStore: LocalDataStoreType {
    private let uniCodeKey = ".uniCodeKey"
    private let rangeKey = ".rangeKey"
    private let startDateKey = ".startDateKey"
    private let endDateKey = ".endDateKey"
    private let languageKey = ".languageKey"
    private let randomStr = ".sieje29s82k"
    private let userDefaults = UserDefaults.standard
    
    var bundleId: String {
        return Bundle.main.bundleIdentifier!
    }
    
    func storeUniCode(type: EncodingType) {
        let key = bundleId + randomStr + uniCodeKey
        userDefaults.setValue(type.rawValue, forKey: key)
        }
    
    func restoreUniCode() -> EncodingType? {
        let key = bundleId + randomStr + uniCodeKey
        let value = UserDefaults.standard.integer(forKey: key)
        return EncodingType(rawValue: value)
    }
    
    func storeRange(type: RangeType) {
        let key = bundleId + randomStr + rangeKey
        userDefaults.setValue(type.rawValue, forKey: key)
        }
    
    func restoreRange() -> RangeType? {
        let key = bundleId + randomStr + rangeKey
        let value = UserDefaults.standard.integer(forKey: key)
        return RangeType(rawValue: value)
    }
    
    func storeStart(date: Date) {
        let key = bundleId + randomStr + startDateKey
        UserDefaults.standard.setValue(date, forKey: key)
    }
    
    func restoreStartDate() -> Date? {
        let key = bundleId + randomStr + startDateKey
        let value = UserDefaults.standard.object(forKey: key)
        return value as? Date
    }
    
    func storeEnd(date: Date) {
        let key = bundleId + randomStr + endDateKey
        userDefaults.setValue(date, forKey: key)
        }
    
    func restoreEndDate() -> Date? {
        let key = bundleId + randomStr + endDateKey
        let value = UserDefaults.standard.object(forKey: key)
        return value as? Date
    }
    
    func storeLanguage(type: LanguageType) {
        let key = bundleId + randomStr + languageKey
        userDefaults.setValue(type.rawValue, forKey: key)
    }
    
    func restoreLanguage() -> LanguageType? {
        let key = bundleId + randomStr + languageKey
        guard let value = UserDefaults.standard.object(forKey: key) as? String else { return nil }
        return LanguageType(rawValue: value)
    }
}
