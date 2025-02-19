//
//  Const.swift
//  LifeLogApp
//
//  Created by ShinUnuma on 2021/09/29.
//

import Foundation

enum ExportType {
    case all
    case tags
    case search
    case calendar
    case edit
    
    var title: String {
        return String.localize.menu.csvTitle
    }
    
    var message: String {
        switch self {
        case .all: return String.localize.menu.csvMessage
        case .tags: return String.localize.tags.message
        case .search: return String.localize.searchResults.message
        case .calendar: return String.localize.calendar.message
        case .edit: return String.localize.logDetail.csvTitle
        }
    }
}

enum EncodingType: Int, CaseIterable {
    case utf8Bom
    case utf8
    case shitjis
    case big5
    case gb2312
    
    var encoding: String.Encoding {
        switch self {
        case .utf8Bom, .utf8: return .utf8
        case .shitjis: return .shiftJIS
        case .big5:
            let cfBig5 = CFStringEncoding(CFStringEncodings.big5.rawValue)
            return String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(cfBig5))
        case .gb2312:
            let gb2312 = CFStringEncoding(CFStringEncodings.GB_2312_80.rawValue)
            return String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(gb2312))
        }
    }
    
    var exportTitle: String {
        switch self {
        case .utf8Bom: return String.localize.logDetail.csvUtf8Bom
        case .utf8: return String.localize.logDetail.csvUtf8
        case .shitjis: return String.localize.logDetail.csvShiftJis
        case .big5: return String.localize.logDetail.csvBig5
        case .gb2312: return String.localize.logDetail.csvGb2312
        }
    }
    
    var selectTitle: String {
        switch self {
        case .utf8Bom: return String.localize.settings.aboutUtf8BomTitle
        case .utf8: return String.localize.settings.aboutUtf8Title
        case .shitjis: return String.localize.settings.aboutShiftJisTitle
        case .big5: return String.localize.settings.aboutBig5Title
        case .gb2312: return String.localize.settings.aboutGB2312Title
        }
    }
}

struct CustomURL {
    static var url: URL? = nil
    static var isImportExtension: Bool {
        return url?.pathExtension == "letslog" || url?.pathExtension == "csv"
    }
}
