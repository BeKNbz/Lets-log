//
//  StringZhTW.swift
//  LifeLogApp
//
//  Created by ShinUnuma on 2022/02/05.
//

import Foundation

struct StringZhTW: StringLocalizable {
    let menu: LocalizeMenu = LocalizeMenuZhTW()
    let settings: LocalizeSettings = LocalizeSettingsZhTW()
    let allLog: LocalizeAllLogs = LocalizeAllLogsZhTW()
    let logDetail: LocalizeLogDetail = LocalizeLogDetailZhTW()
    let changeDate: LocalizeChangeDate = LocalizeChangeDateZhTW()
    let editLog: LocalizeEditLog = LocalizeEditLogZhTW()
    let calendar: LocalizeCalendar = LocalizeCalendarZhTW()
    let searchResults: LocalizeSearchResults = LocalizeSearchResultsZhTW()
    let tags: LocalizeTags = LocalizeTagsZhTW()
    let dateFormat: LocalizeDateFormat = LocalizeDateFormatZhTW()
    let backup: LocalizeBackup = LocalizeBackupZhTW()
    
    struct LocalizeMenuZhTW: LocalizeMenu {
        let title: String = "菜單"
        let calendar: String = "日曆"
        let allLog: String = "所有日誌"
        let tags: String = "按標籤"
        let csvTitle: String = "將日誌輸出為CSV文件"
        let csvMessage: String = "將所有日誌輸出到CSV文件"
        let csvExe: String = "是的"
        let csvCancel: String = "取消"
        let newLog: String = "新日誌..."
        let confirm: String = "確認"
        let close: String = "特寫"
    }
    
    struct LocalizeSettingsZhTW: LocalizeSettings {
        let title: String = "設置"
        let selectLanguage: String = "語言切換"
        let privacyPolicy: String = "隱私政策"
        let termOfService: String = "服務條款"
        let unicode: String = "字符代碼"
        let exportRange: String = "輸出範圍"
        let dateRange: String = "按日期指定"
        let allRange: String = "一次處理所有日誌"
        let rangeMessage: String = "* 批次輸出可能需要一些時間，具體取決於日誌數量"
        let exportTitle: String = "輸出"
        let importTitle: String = "輸入"
        let aboutUnicodeTitle: String = "關於字符代碼"
        let aboutUnicodeMessge: String = "導出時可以從以下選項中選擇"
        let aboutUtf8BomTitle: String = "UTF-8(BOM)"
        let aboutUtf8BomMessage: String = "這是一種通過添加BOM（推薦）來防止MSExcel中出現亂碼的文件格式"
        let aboutUtf8Title: String = "UTF-8"
        let aboutUtf8Message: String = "MSExcel中的字符可能出現亂碼"
        let aboutShiftJisTitle: String = "Shift_JIS"
        let aboutShiftJisMessage: String = "iPhone預覽中的字符可能會出現亂碼"
        let aboutBig5Title: String = "Big5"
        let aboutBig5Message: String = ""
        let aboutGB2312Title: String = "GB2312"
        let aboutGB2312Message: String = ""
        let outOfRangeMessage: String = "找不為指定範圍的日誌"
        let exportCSV: String = "輸出為CSV文件"
        let exportBackup: String = "備份輸出"
        let importTypeMessage: String = ""
        let importTitleCustom: String = ""
        let importTitleCsv: String = ""
    }
    
    struct LocalizeAllLogsZhTW: LocalizeAllLogs {
        let title: String = "所有日誌"
        let dateFormat: String = "例）10月11日(四)"
        let cancel: String = "取消"
        let search: String = "搜索"
    }
    
    struct LocalizeLogDetailZhTW: LocalizeLogDetail {
        let title: String = "編輯"
        let csvTitle: String = "將日誌輸出到CSV文件"
        let csvUtf8Bom: String = "以UTF-8(BOM)輸出 (推薦）"
        let csvUtf8: String = "以UTF-8輸出"
        let csvShiftJis: String = "以Shift_JIS輸出"
        let csvBig5: String = "以Big5輸出"
        let csvGb2312: String = "以GB2312輸出"
    }
    
    struct LocalizeChangeDateZhTW: LocalizeChangeDate {
        let title: String = "改變日期"
        let done: String = "完成"
        let formatExample: String = "例）2021年10月"
        let weekTitle: String = "一二三四五六日"
        let fromDate: String = "從何時"
        let setCurrent: String = "設置當前日期和時間"
    }
    
    struct LocalizeEditLogZhTW: LocalizeEditLog {
        let title: String = "編輯日誌"
        let emptyLog: String = "空日誌"
    }
    
    struct LocalizeCalendarZhTW: LocalizeCalendar {
        let message: String = "%@創建的日誌輸出為CSV文件"
        let emptyMessage: String = """
        尚未有%@的日誌
        請登錄
        """
        let deleteMessage: String = "刪除日誌. 可以嗎？"
        let delete: String = "刪除"
    }
    
    struct LocalizeSearchResultsZhTW: LocalizeSearchResults {
        let message: String = "將搜索結果日誌輸出為CSV文件"
    }
    
    struct LocalizeTagsZhTW: LocalizeTags {
        let message: String = "將包含標籤的日誌輸出為CSV文件"
    }
    
    struct LocalizeDateFormatZhTW: LocalizeDateFormat {
        let MMddEE: String = "MM月dd日（E）"
        let Md: String = "M月d日(E)"
        let yyyyMMddEE: String = "yyyy年MM月dd日（E）"
        let yyyyMMddEEhhmm: String = "yyyy年MM月dd日（E）HH:mm"
        let yyyyMM: String = "yyyy年MM月"
        let yyyyMMdd: String = "yyyy年MM月dd日"
        let MM: String = "MM月"
    }
    
    struct LocalizeBackupZhTW: LocalizeBackup {
        let loading: String = "正在加載文件..."
        let checked: String = "我檢查了備份數據. 你想捕捉數據嗎？"
        let csvType: String = "以下哪個是此 CSV 文件的字符代碼？ （導入時需要轉換）"
        let completed: String = "備份數據導入完成"
        let notFound: String = "未找到備份數據"
        let failedRead: String = "讀取備份數據失敗"
    }
    
}
