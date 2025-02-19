//
//  UpdateTextViewController.swift
//  LifeLogApp
//
//  Created by ShinUnuma on 2021/07/09.
//

import UIKit
import RxSwift
import KRProgressHUD

class UpdateTextViewController: UIViewController {
    @IBOutlet private weak var inputField: UITextView! {
        didSet {
            inputField.textContainerInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
            inputField.delegate = self
        }
    }
    @IBOutlet private weak var tagsButton: UIBarButtonItem!
    @IBOutlet private weak var inputFieldBottom: NSLayoutConstraint!
    @IBOutlet private weak var doneButton: UIBarButtonItem!
    private let viewModel = UpdateTextViewModel()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubscription()
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillHidden), name: UIResponder.keyboardWillHideNotification, object: nil)
        inputField.text = viewModel.text
        viewModel.fetchTags()
        navigationItem.title = String.localize.editLog.title
        doneButton.title = String.localize.changeDate.done
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        inputField.becomeFirstResponder()
    }
    
    func setup(logDetail: LogDetail) {
        viewModel.setup(logDetail: logDetail)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        inputTextAnimation(height: keyboardSize.height)
    }
    
    @objc func keyboardWillHidden(notification: NSNotification) {
        inputTextAnimation(height: 0)
    }
    
    private func inputTextAnimation(height: CGFloat) {
        if inputFieldBottom.constant == height { return }
        inputFieldBottom.constant = height
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       options: .curveEaseOut,
                       animations: { [weak self] in
                        self?.view.layoutIfNeeded()
                       })
    }
    
    private func presentSelectTagSheet() {
        if viewModel.tags.isEmpty { return }
        let actionList = viewModel.tags.compactMap { tag in
            UIAlertAction(title: tag.name, style: .default) { [weak self] _ in
                self?.inputField.text.append(" \(tag.name)")
            }
        }
        presentActionSheet(actionList: actionList)
    }

    //完了ボタンのタップ時の挙動
    //テキストの変更を検出し、変更がある場合は更新、ない場合はビューコントローラーを閉じる
    @IBAction func onClickDone() {
        guard let text = inputField.text else { return }
        if viewModel.isChange(text: text) {
            viewModel.update(text: text)
        } else {
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func onClickTags() {
        inputField.resignFirstResponder()
        presentSelectTagSheet()
    }
}

extension UpdateTextViewController: UITextViewDelegate {
    
}

extension UpdateTextViewController {
    private func setupSubscription() {
        viewModel.isLoading.main
            .subscribe(onNext: { isLoading in
                KRProgressHUD.showOrDismiss(isLoading: isLoading)
            }).disposed(by: disposeBag)
        
        viewModel.completedUpdated.main
            .subscribe(onNext: { [weak self] updated in
                let center = NotificationCenter.default
                let userInfo = [NotificationUserInfoKey.updatedLogDetail.rawValue: updated]
                center.post(name: .updateLogDetail, object: nil, userInfo: userInfo)
                center.post(name: .reloadTop, object: nil, userInfo: nil)
                self?.dismiss(animated: true)
            }).disposed(by: disposeBag)
        
        viewModel.isEmptyTags.main
            .subscribe(onNext: { [weak self] isEmpty in
                self?.tagsButton.isEnabled = !isEmpty
                self?.tagsButton.tintColor = !isEmpty ? UIColor.blue : UIColor.clear
            }).disposed(by: disposeBag)
        
        viewModel.errorMessage.main
            .subscribe(onNext: { [weak self] message in
                self?.presentAlert(message: message)
            }).disposed(by: disposeBag)
    }
}
