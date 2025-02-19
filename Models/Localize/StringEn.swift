//
//  StringEn.swift
//  LifeLogApp
//
//  Created by ShinUnuma on 2022/02/05.
//

import Foundation

struct StringEn: StringLocalizable {
    let menu: LocalizeMenu = LocalizeMenuEn()
    let settings: LocalizeSettings = LocalizeSettingsEn()
    let allLog: LocalizeAllLogs = LocalizeAllLogsEn()
    let logDetail: LocalizeLogDetail = LocalizeLogDetailEn()
    let changeDate: LocalizeChangeDate = LocalizeChangeDateEn()
    let editLog: LocalizeEditLog = LocalizeEditLogEn()
    let calendar: LocalizeCalendar = LocalizeCalendarEn()
    let searchResults: LocalizeSearchResults = LocalizeSearchResultsEn()
    let tags: LocalizeTags = LocalizeTagsEn()
    let dateFormat: LocalizeDateFormat = LocalizeDateFormatEn()
    let backup: LocalizeBackup = LocalizeBackupEn()
    
    struct LocalizeMenuEn: LocalizeMenu {
        let title: String = "Menu"
        let calendar: String = "Calendar"
        let allLog: String = "All logs"
        let tags: String = "By tag"
        let csvTitle: String = "Export to CSV"
        let csvMessage: String = "Export all logs to CSV file"
        let csvExe: String = "Yes"
        let csvCancel: String = "Cancel"
        let newLog: String = "New log ..."
        let confirm: String = "Confirmation"
        let close: String = "Close"
    }
    
    struct LocalizeSettingsEn: LocalizeSettings {
        let title: String = "Settings"
        let selectLanguage: String = "Select language"
        let privacyPolicy: String = "Privacy Policy"
        let termOfService: String = "Terms of service"
        let unicode: String = "Character code"
        let exportRange: String = "Export Range"
        let dateRange: String = "Date Range"
        let allRange: String = "All logs"
        let rangeMessage: String = "* This may take some time depending on the number of logs."
        let exportTitle: String = "Export"
        let importTitle: String = "Import"
        let aboutUnicodeTitle: String = "About character code"
        let aboutUnicodeMessge: String = "You can select from the following"
        let aboutUtf8BomTitle: String = "UTF-8 (BOM)"
        let aboutUtf8BomMessage: String = "The code that prevents garbled characters in MS Excel by adding BOM (recommended)."
        let aboutUtf8Title: String = "UTF-8"
        let aboutUtf8Message: String = "Characters may be garbled in MS Excel"
        let aboutShiftJisTitle: String = "Shift_JIS"
        let aboutShiftJisMessage: String = "Characters may be garbled in iPhone preview"
        let aboutBig5Title: String = "Big5"
        let aboutBig5Message: String = ""
        let aboutGB2312Title: String = "GB2312"
        let aboutGB2312Message: String = ""
        let outOfRangeMessage: String = "The specified range of logs could not be found"
        let exportCSV: String = "Output to CSV file"
        let exportBackup: String = "Output for backup"
        let importTypeMessage: String = ""
        let importTitleCustom: String = ""
        let importTitleCsv: String = ""
    }
    
    struct LocalizeAllLogsEn: LocalizeAllLogs {
        let title: String = "All logs"
        let dateFormat: String = "30 Jan. (Mon)"
        let cancel: String = "Cancel"
        let search: String = "Search"
    }
    
    struct LocalizeLogDetailEn: LocalizeLogDetail {
        let title: String = "Edit"
        let csvTitle: String = "Export the log to a CSV file."
        let csvUtf8Bom: String = "UTF-8 (BOM) (Recommended)"
        let csvUtf8: String = "UTF-8 code"
        let csvShiftJis: String = "Shift_JIS code Japanese"
        let csvBig5: String = "Big5 code Traditional Chinese"
        let csvGb2312: String = "GB2312 Simplified Chinese"
    }
    
    struct LocalizeChangeDateEn: LocalizeChangeDate {
        let title: String = "Change date"
        let done: String = "Set"
        let formatExample: String = "30 Jan. (Mon)"
        let weekTitle: String = "Mon, Tue, Wed, Thu, Fri, Sat, Sun"
        let fromDate: String = "From"
        let setCurrent: String = "Set Current date/time"
    }
    
    struct LocalizeEditLogEn: LocalizeEditLog {
        let title: String = "Edit logs"
        let emptyLog: String = "Empty log"
    }
    
    struct LocalizeCalendarEn: LocalizeCalendar {
        let message: String = "Export the log of %@. as  CSV."
        let emptyMessage: String = """
        No log for %@ yet
        Let's log
        """
        let deleteMessage: String = "Delete the log. Is it OK?"
        let delete: String = "Delete"
    }
    
    struct LocalizeSearchResultsEn: LocalizeSearchResults {
        let message: String = "Export the search result log as CSV."
    }
    
    struct LocalizeTagsEn: LocalizeTags {
        let message: String = "Export the log containing the tag as CSV."
    }
    
    struct LocalizeDateFormatEn: LocalizeDateFormat {
        let MMddEE: String = "dd MMM.(E)"
        let Md: String = "d M.(E)"
        let yyyyMMddEE: String = "dd MMM. yyyy(E)"
        let yyyyMMddEEhhmm: String = "dd MMM. yyyy(E) HH:mm"
        let yyyyMM: String = "MMM. yyyy"
        let yyyyMMdd: String = "dd MMM. yyyy"
        let MM: String = "MMM."
    }
    
    struct LocalizeBackupEn: LocalizeBackup {
        let loading: String = "Loading the file ..."
        let checked: String = "Identified the import data. Import?"
        let csvType: String = "What is the character code of this CSV file? (Necessary for data conversion)"
        let completed: String = "Import from backup is succeeded."
        let notFound: String = "Backup data was not found."
        let failedRead: String = "Failed to read the backup data."
    }
    
}
