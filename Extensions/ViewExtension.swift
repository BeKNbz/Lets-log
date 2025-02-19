//
//  ViewExtension.swift
//  LifeLogApp
//
//  Created by ShinUnuma on 2021/07/07.
//

import UIKit

extension UIView {
    func add(borderWidth: CGFloat = 0, radius: CGFloat = 0, color: UIColor) {
        self.layer.borderWidth = borderWidth
        self.layer.cornerRadius = 10.0
        self.layer.borderColor = color.cgColor
    }
}
