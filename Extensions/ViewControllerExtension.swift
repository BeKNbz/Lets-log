//
//  ViewControllerExtension.swift
//  LifeLogApp
//
//  Created by ShinUnuma on 2021/07/06.
//

import UIKit

extension UIViewController {
    func push(name: StoryboardName) {
        if let viewController = instantiateInitialView(name: name) {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func present(name: StoryboardName,
                 presentstyle: UIModalPresentationStyle = .formSheet,
                 transitionStyle: UIModalTransitionStyle? = nil,
                 completion: (() -> Void)? = nil) {
        if let viewController = instantiateInitialView(name: name) {
            viewController.modalPresentationStyle = presentstyle
            if let transitionStyle = transitionStyle {
                viewController.modalTransitionStyle = transitionStyle
            }
            self.present(viewController, animated: true, completion: completion)
        }
    }
    
    func instantiateInitialView<V: UIViewController>(name: StoryboardName) -> V? {
        let storyboard = UIStoryboard(name: name.rawValue, bundle: nil)
        guard let viewController = storyboard.instantiateInitialViewController() else { return nil }
        return viewController as? V
    }
    
    func instantiateView<V: UIViewController>(name: StoryboardName, identifier: String) -> V? {
        let storyboard = UIStoryboard(name: name.rawValue, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: identifier) as? V
    }
    
    func presentAlert(title: String? = nil,
                      message: String,
                      positiveButton: AlertButton? = nil,
                      negativeButton: AlertButton = .confirm,
                      positiveHandler:(() -> Void)? = nil,
                      negativeHandler: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if let positiveButton = positiveButton {
            let positive = UIAlertAction(title: positiveButton.title,
                                         style: .default) { _ in
                positiveHandler?()
            }
            alert.addAction(positive)
            alert.preferredAction = positive
        }
        let negative = UIAlertAction(title: negativeButton.title, style: .cancel) { _ in
            negativeHandler?()
        }
        alert.addAction(negative)
        self.present(alert, animated: true)
    }
    
    func presentActionSheet(title: String? = nil,
                            message: String? = nil,
                            actionList: [UIAlertAction],
                            isShowCancel: Bool = true,
                            cancelHandler: ((UIAlertAction) -> Void)? = nil) {
        let sheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        actionList.forEach { action in
            sheet.addAction(action)
        }
        if isShowCancel {
            let cancel = UIAlertAction(title: AlertButton.cancel.title, style: .cancel, handler: cancelHandler)
            sheet.addAction(cancel)
        }
        self.present(sheet, animated: true)
    }
    
    static func frontViewController() -> UIViewController? {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        var vc = windowScene?.windows.first { $0.isKeyWindow }?.rootViewController
        while vc?.presentedViewController != nil {
            vc = vc?.presentedViewController
        }
        return vc
    }
    
    static func presentImportFileViewController(url: URL) {
        if let fontViewController = UIViewController.frontViewController(), let importFile = UIStoryboard(name: StoryboardName.importFile.rawValue, bundle: nil).instantiateInitialViewController() as? ImportFileViewController {
            importFile.setup(url: url)
            importFile.modalPresentationStyle = .fullScreen
            importFile.modalTransitionStyle = .crossDissolve
            fontViewController.present(importFile, animated: true)
        }
    }
}

enum StoryboardName: String {
    case main = "Main"
    case calendar = "Calendar"
    case logList = "LogList"
    case edit = "Edit"
    case updateText = "UpdateText"
    case updateDate = "UpdateDate"
    case selectTime = "SelectTime"
    case settings = "Settings"
    case export = "Export"
    case importFile = "ImportFile"
}

enum AlertButton: String {
    case ok
    case no
    case confirm
    case cancel
    case delete
    case close
    
    var title: String {
        switch self {
        case .ok: return String.localize.menu.csvExe
        case .no: return String.localize.menu.csvCancel
        case .confirm: return String.localize.menu.confirm
        case .cancel: return String.localize.menu.csvCancel
        case .delete: return String.localize.calendar.delete
        case .close: return String.localize.menu.close
        }
    }
}
