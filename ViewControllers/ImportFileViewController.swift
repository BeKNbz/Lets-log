//
//  ImportFileViewController.swift
//  LifeLogApp
//
//  Created by ShinUnuma on 2022/02/09.
//

import UIKit
import RxSwift
import KRProgressHUD

class ImportFileViewController: UIViewController {
    private let viewModel = ImportFileViewModel()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubscription()
        showReadProgressBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.readFile()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        KRProgressHUD.dismiss()
    }

    func setup(url: URL) {
        viewModel.setup(url: url)
    }
    
    private func showReadProgressBar() {
        KRProgressHUD.set(style: .custom(background: .white, text: .gray, icon: nil))
            .set(maskType: .black)
            .show(withMessage: String.localize.backup.loading)
    }
    
    private func showComfirmImportAlert() {
        KRProgressHUD.dismiss() {
            DispatchQueue.main.async { [weak self] in
                self?.presentAlert(
                    title: nil,
                    message: String.localize.backup.checked,
                    positiveButton: .ok,
                    negativeButton: .cancel,
                    positiveHandler: { [weak self] in
                        guard let `self` = self else { return }
                        self.viewModel.saveLogDetails().disposed(by: self.disposeBag)
                    },
                    negativeHandler: { [weak self] in
                        self?.dismiss(animated: true)
                    }
                )
            }
        }
    }
    
    private func showConfirmCSVTypeAlert(url: URL) {
        KRProgressHUD.dismiss() {
            DispatchQueue.main.async { [weak self] in
                let actionList: [UIAlertAction] = EncodingType.allCases.map { type in
                    UIAlertAction(title: type.selectTitle, style: .default) { [weak self] _ in
                        self?.viewModel.readCSVFile(url: url, type: type)
                    }
                }
                self?.presentActionSheet(
                    title: nil,
                    message: String.localize.backup.csvType,
                    actionList: actionList,
                    isShowCancel: true
                )
            }
        }
    }
    
    private func showCompleteReadFileAlert() {
        presentAlert(
            title: nil,
            message: String.localize.backup.completed,
            negativeButton: .confirm,
            negativeHandler: { [weak self] in
            
            self?.dismiss(animated: true)
        })
    }
}

extension ImportFileViewController {
    private func setupSubscription() {
        viewModel.isLoading.main
            .subscribe(onNext: { isLoading in
                KRProgressHUD.showOrDismiss(isLoading: isLoading)
            }).disposed(by: disposeBag)
        viewModel.confirmSave.main
            .subscribe(onNext: { [weak self] in
                self?.showComfirmImportAlert()
            }).disposed(by: disposeBag)
        viewModel.confirmCSVType.main
            .subscribe(onNext: { [weak self] url in
                self?.showConfirmCSVTypeAlert(url: url)
            }).disposed(by: disposeBag)
        viewModel.completed.main
            .subscribe(onNext: { [weak self] in
                self?.showCompleteReadFileAlert()
            }).disposed(by: disposeBag)
        viewModel.failedMessage.main
            .subscribe(onNext: { [weak self] message in
                self?.presentAlert(message: message, negativeHandler: { [weak self] in
                    self?.dismiss(animated: true)
                })
            }).disposed(by: disposeBag)
    }
}
