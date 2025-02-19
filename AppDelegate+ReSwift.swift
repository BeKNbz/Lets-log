//
//  AppDelegate+ReSwift.swift
//  LifeLogApp
//
//  Created by ShinUnuma on 2022/02/05.
//

import ReSwift

let mainStore = Store<StringLocalizable>(
    reducer: localizeReducer,
    state: String.localize
)

struct ChangeLanguageJpAction: Action {}
struct ChangeLanguageEnAction: Action {}
struct ChangeLanguageZhCNAction: Action {}
struct ChangeLanguageZhTWAction: Action {}

func localizeReducer(action: Action, state: StringLocalizable?) -> StringLocalizable {
    switch action {
    case _ as ChangeLanguageJpAction: return StringJp()
    case _ as ChangeLanguageEnAction: return StringEn()
    case _ as ChangeLanguageZhCNAction: return StringZhCN()
    case _ as ChangeLanguageZhTWAction: return StringZhTW()
    default: return state ?? String.localize
    }
}
