//
//  StringJp.swift
//  LifeLogApp
//
//  Created by ShinUnuma on 2022/02/05.
//

import Foundation

struct StringJp: StringLocalizable {
    let menu: LocalizeMenu = LocalizeMenuJp()
    let settings: LocalizeSettings = LocalizeSettingsJp()
    let allLog: LocalizeAllLogs = LocalizeAllLogsJp()
    let logDetail: LocalizeLogDetail = LocalizeLogDetailJp()
    let changeDate: LocalizeChangeDate = LocalizeChangeDateJp()
    let editLog: LocalizeEditLog = LocalizeEditLogJp()
    let calendar: LocalizeCalendar = LocalizeCalendarJp()
    let searchResults: LocalizeSearchResults = LocalizeSearchResultsJp()
    let tags: LocalizeTags = LocalizeTagsJp()
    let dateFormat: LocalizeDateFormat = LocalizeDateFormatJp()
    let backup: LocalizeBackup = LocalizeBackupJp()
    
    struct LocalizeMenuJp: LocalizeMenu {
        let title: String = "メニュー"
        let calendar: String = "カレンダー"
        let allLog: String = "全てのログ"
        let tags: String = "タグ別"
        let csvTitle: String = "CSVファイルの作成"
        let csvMessage: String = "全てのログをCSVファイルに出力します"
        let csvExe: String = "はい"
        let csvCancel: String = "キャンセル"
        let newLog: String = "新規ログ…"
        let confirm: String = "確認"
        let close: String = "閉じる"
    }
    
    struct LocalizeSettingsJp: LocalizeSettings {
        let title: String = "設定"
        let selectLanguage: String = "言語切り替え"
        let privacyPolicy: String = "プライバシーポリシー"
        let termOfService: String = "利用規約"
        let unicode: String = "文字コード"
        let exportRange: String = "出力範囲"
        let dateRange: String = "日付で指定"
        let allRange: String = "全件一括"
        let rangeMessage: String = "※一括での出力は件数によって時間がかかる場合があります"
        let exportTitle: String = "エクスポート"
        let importTitle: String = "インポート"
        let aboutUnicodeTitle: String = "文字コードについて"
        let aboutUnicodeMessge: String = "エクスポート時に次から選択できます"
        let aboutUtf8BomTitle: String = "UTF-8(BOM)"
        let aboutUtf8BomMessage: String = "BOMをつけることでMS Excelで文字化けしないようにしたファイル形式です（推奨）"
        let aboutUtf8Title: String = "UTF-8"
        let aboutUtf8Message: String = "MS Excelで文字化けすることがあります"
        let aboutShiftJisTitle: String = "Shift_JIS"
        let aboutShiftJisMessage: String = "iPhoneプレビューで文字化けすることがあります"
        let aboutBig5Title: String = "Big5"
        let aboutBig5Message: String = ""
        let aboutGB2312Title: String = "GB2312"
        let aboutGB2312Message: String = ""
        let outOfRangeMessage: String = "指定した範囲のログが見つかりませんでした"
        let exportCSV: String = "CSVファイルに出力する"
        let exportBackup: String = "バックアップ用に出力する"
        let importTypeMessage: String = "端末のファイルAPPからファイルをインポートします。インポートする形式を選択してください。"
        let importTitleCustom: String = "バックアップデータ"
        let importTitleCsv: String = "CSVファイル"
    }
    
    struct LocalizeAllLogsJp: LocalizeAllLogs {
        let title: String = "全てのログ"
        let dateFormat: String = "例）10月11日(月)"
        let cancel: String = "キャンセル"
        let search: String = "検索"
    }
    
    struct LocalizeLogDetailJp: LocalizeLogDetail {
        let title: String = "編集"
        let csvTitle: String = "ログをCSVファイルに出力します"
        let csvUtf8Bom: String = "UTF-8(BOM)で出力"
        let csvUtf8: String = "UTF-8で出力"
        let csvShiftJis: String = "Shift_JISで出力"
        let csvBig5: String = "Big5で出力"
        let csvGb2312: String = "GB2312で出力"
    }
    
    struct LocalizeChangeDateJp: LocalizeChangeDate {
        let title: String = "日付の変更"
        let done: String = "完了"
        let formatExample: String = "例）2021年10月"
        let weekTitle: String = "月火水木金土日"
        let fromDate: String = "開始"
        let setCurrent: String = "現在日時を設定"
    }
    
    struct LocalizeEditLogJp: LocalizeEditLog {
        let title: String = "ログの編集"
        let emptyLog: String = "空のログ"
    }
    
    struct LocalizeCalendarJp: LocalizeCalendar {
        let message: String = "%@に作成されたログをCSVファイルに出力します"
        let emptyMessage: String = """
        %@のログはまだありません
        ログを記録しましょう
        """
        let deleteMessage: String = "ログを削除します。よろしいですか？"
        let delete: String = "削除"
    }
    
    struct LocalizeSearchResultsJp: LocalizeSearchResults {
        let message: String = "検索結果のログをCSVファイルに出力します"
    }
    
    struct LocalizeTagsJp: LocalizeTags {
        let message: String = "タグを含んだログをCSVファイルに出力します"
    }
    
    struct LocalizeDateFormatJp: LocalizeDateFormat {
        let MMddEE: String = "MM月dd日（EE）"
        let Md: String = "M月d日(EE)"
        let yyyyMMddEE: String = "yyyy年MM月dd日（EE）"
        let yyyyMMddEEhhmm: String = "yyyy年MM月dd日（EE）HH:mm"
        let yyyyMM: String = "yyyy年MM月"
        let yyyyMMdd: String = "yyyy年MM月dd日"
        let MM: String = "MM月"
    }
    
    struct LocalizeBackupJp: LocalizeBackup {
        let loading: String = "ファイルを読み込み中..."
        let checked: String = "インポートデータを確認しました。データを取り込みますか？"
        let csvType: String = "このCSVファイルの文字コードは次のどれですか？（インポート時の変換に必要です）"
        let completed: String = "バックアップデータの取り込みが完了しました"
        let notFound: String = "バックアップデータが見つかりませんでした"
        let failedRead: String = "バックアップデータの読み込みに失敗しました"
    }
    
}
