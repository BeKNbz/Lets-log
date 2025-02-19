//
//  StringZhCN.swift
//  LifeLogApp
//
//  Created by ShinUnuma on 2022/02/05.
//

import Foundation

struct StringZhCN: StringLocalizable {
    let menu: LocalizeMenu = LocalizeMenuZhCN()
    let settings: LocalizeSettings = LocalizeSettingsZhCN()
    let allLog: LocalizeAllLogs = LocalizeAllLogsZhCN()
    let logDetail: LocalizeLogDetail = LocalizeLogDetailZhCN()
    let changeDate: LocalizeChangeDate = LocalizeChangeDateZhCN()
    let editLog: LocalizeEditLog = LocalizeEditLogZhCN()
    let calendar: LocalizeCalendar = LocalizeCalendarZhCN()
    let searchResults: LocalizeSearchResults = LocalizeSearchResultsZhCN()
    let tags: LocalizeTags = LocalizeTagsZhCN()
    let dateFormat: LocalizeDateFormat = LocalizeDateFormatZhCN()
    let backup: LocalizeBackup = LocalizeBackupZhCN()
    
    struct LocalizeMenuZhCN: LocalizeMenu {
        let title: String = "菜单"
        let calendar: String = "日历"
        let allLog: String = "所有日志"
        let tags: String = "按标签"
        let csvTitle: String = "将日志输出為CSV文件"
        let csvMessage: String = "将所有日志输出到CSV文件"
        let csvExe: String = "是的"
        let csvCancel: String = "取消"
        let newLog: String = "新日志..."
        let confirm: String = "确认"
        let close: String = "特写"
    }
    
    struct LocalizeSettingsZhCN: LocalizeSettings {
        let title: String = "设置"
        let selectLanguage: String = "语言切换"
        let privacyPolicy: String = "隐私政策"
        let termOfService: String = "服务条款"
        let unicode: String = "字符代码"
        let exportRange: String = "输出范围"
        let dateRange: String = "按日期指定"
        let allRange: String = "一次处理所有日誌"
        let rangeMessage: String = "* 批次输出可能需要一些时间，具体取决于日誌数量"
        let exportTitle: String = "输出"
        let importTitle: String = "输入"
        let aboutUnicodeTitle: String = "关于字符代码"
        let aboutUnicodeMessge: String = "导出时可以从以下选项中选择"
        let aboutUtf8BomTitle: String = "UTF-8(BOM)"
        let aboutUtf8BomMessage: String = "这是一种通过添加BOM（推荐）来防止MSExcel中出现乱码的文件格式"
        let aboutUtf8Title: String = "UTF-8"
        let aboutUtf8Message: String = "MSExcel中的字符可能出现乱码"
        let aboutShiftJisTitle: String = "Shift_JIS"
        let aboutShiftJisMessage: String = "iPhone预览中的字符可能会出现乱码"
        let aboutBig5Title: String = "Big5"
        let aboutBig5Message: String = ""
        let aboutGB2312Title: String = "GB2312"
        let aboutGB2312Message: String = ""
        let outOfRangeMessage: String = "找不為指定范围的日志"
        let exportCSV: String = "输出為CSV文件"
        let exportBackup: String = "备份输出"
        let importTypeMessage: String = ""
        let importTitleCustom: String = ""
        let importTitleCsv: String = ""
    }
    
    struct LocalizeAllLogsZhCN: LocalizeAllLogs {
        let title: String = "所有日志"
        let dateFormat: String = "例）10月11日(四)"
        let cancel: String = "取消"
        let search: String = "搜索"
    }
    
    struct LocalizeLogDetailZhCN: LocalizeLogDetail {
        let title: String = "编辑"
        let csvTitle: String = "将日志输出到CSV文件"
        let csvUtf8Bom: String = "以UTF-8(BOM)输出 (推荐)"
        let csvUtf8: String = "以UTF-8输出"
        let csvShiftJis: String = "以Shift_JIS输出"
        let csvBig5: String = "以Big5输出"
        let csvGb2312: String = "以GB2312输出"
    }
    
    struct LocalizeChangeDateZhCN: LocalizeChangeDate {
        let title: String = "改变日期"
        let done: String = "完成"
        let formatExample: String = "例）2021年10月"
        let weekTitle: String = "一二三四五六日"
        let fromDate: String = "从何時"
        let setCurrent: String = "设置当前日期和时间"
    }
    
    struct LocalizeEditLogZhCN: LocalizeEditLog {
        let title: String = "编辑日志"
        let emptyLog: String = "空日志"
    }
    
    struct LocalizeCalendarZhCN: LocalizeCalendar {
        let message: String = "%@创建的日志输出為CSV文件"
        let emptyMessage: String = """
        尚未有%@的日志
        请登录
        """
        let deleteMessage: String = "删除日志. 可以吗？"
        let delete: String = "删除"
    }
    
    struct LocalizeSearchResultsZhCN: LocalizeSearchResults {
        let message: String = "将搜索结果日志输出為CSV文件"
    }
    
    struct LocalizeTagsZhCN: LocalizeTags {
        let message: String = "将包含标签的日志输出為CSV文件"
    }
    
    struct LocalizeDateFormatZhCN: LocalizeDateFormat {
        let MMddEE: String = "MM月dd日（E）"
        let Md: String = "M月d日(E)"
        let yyyyMMddEE: String = "yyyy年MM月dd日（E）"
        let yyyyMMddEEhhmm: String = "yyyy年MM月dd日（E）HH:mm"
        let yyyyMM: String = "yyyy年MM月"
        let yyyyMMdd: String = "yyyy年MM月dd日"
        let MM: String = "MM月"
    }
    
    struct LocalizeBackupZhCN: LocalizeBackup {
        let loading: String = "正在加载文件..."
        let checked: String = "我检查了备份数据. 你想捕捉数据吗？"
        let csvType: String = "以下哪个是此 CSV 文件的字符代码？ （导入时需要转换）"
        let completed: String = "备份数据导入完成"
        let notFound: String = "未找到备份数据"
        let failedRead: String = "读取备份数据失败"
    }
    
}
