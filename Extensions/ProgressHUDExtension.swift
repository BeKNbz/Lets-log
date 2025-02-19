//
//  ProgressHUDExtension.swift
//  LifeLogApp
//
//  Created by ShinUnuma on 2021/07/07.
//

import KRProgressHUD

extension KRProgressHUD {
    static func showOrDismiss(isLoading: Bool) {
        if isLoading {
            KRProgressHUD
                .set(style: .custom(background: .clear, text: .clear, icon: .clear))
                .set(maskType: .clear)
                .set(activityIndicatorViewColors: [UIColor]([.darkGray, .white]))
                .show()
        } else {
            KRProgressHUD.dismiss()
        }
    }
}
