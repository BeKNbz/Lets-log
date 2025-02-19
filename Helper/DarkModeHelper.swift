//
//  DarkModeHelper.swift
//  LifeLogApp
//
//  Created by ShinUnuma on 2021/07/12.
//

import UIKit

class DarkModeHelper {
    static var isDarkMode: Bool  {
        if #available(iOS 13.0, *) {
            return UITraitCollection.current.userInterfaceStyle == .dark
        } else {
            return false
        }
    }
}

