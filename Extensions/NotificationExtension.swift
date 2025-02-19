//
//  NotificationExtension.swift
//  LifeLogApp
//
//  Created by ShinUnuma on 2021/07/09.
//

import Foundation

extension Notification.Name {
    static let reloadTop = Notification.Name("reloadTop")
    static let updateLogDetail = Notification.Name("updateLogDetail")
    static let updateCreateTime = Notification.Name("updateCreateTime")
}

enum NotificationUserInfoKey: String {
    case updatedLogDetail
    case updatedCreateTime
}
