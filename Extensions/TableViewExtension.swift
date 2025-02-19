//
//  TableViewExtension.swift
//  LifeLogApp
//
//  Created by ShinUnuma on 2022/02/09.
//

import UIKit

extension UITableView {
    func topPaddingZero() {
        if #available(iOS 15.0, *) {
            sectionHeaderTopPadding = 0
        }
    }
}
