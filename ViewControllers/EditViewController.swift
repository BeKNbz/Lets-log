//
//  EditViewController.swift
//  LifeLogApp
//
//  Created by ShinUnuma on 2021/07/09.
//

import UIKit
import RxSwift
import KRProgressHUD
import FloatingPanel
import ActiveLabel

class EditViewController: UIViewController {
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var detailLabel: ActiveLabel! {
        didSet {
            detailLabel.enabledTypes = [custom]
            detailLabel.customColor[custom] = UIColor.tagColor
        }
    }
    @IBOutlet private weak var arrowRight: UIImageView!
    @IBOutlet private weak var editButton: UIButton!
    let custom = ActiveType.custom(pattern: "#[^#\\s]*")
    private let viewModel = EditViewModel()
    private let disposeBag = DisposeBag()

    //ビューコントローラーがメモリに読み込まれた後の設定処理(「＞」画像の読み込みも含む）
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubscription()
        setup()
        let image = UIImage(named: DarkModeHelper.isDarkMode ? "arrow_right_d" : "arrow_right")?
            .withAlignmentRectInsets(UIEdgeInsets(top: -3, left: 0, bottom: -3, right: 0))
        arrowRight.image = image
        editButton.setTitle(String.localize.logDetail.title, for: .normal)
    }
    
    func setup(logDetail: LogDetail, tagList: [Tag]) {
        viewModel.setup(logDetail: logDetail, tagList: tagList)
    }
    
    private func setup() {
        guard let logDetail = viewModel.logDetail else { return }
        dateLabel.text = viewModel.createDate()
        if logDetail.text.isEmpty {
            detailLabel.textColor = .emptyTextLabel
            detailLabel.text = String.localize.editLog.emptyLog
        } else {
            detailLabel.textColor = .textLabel
            detailLabel.text = logDetail.text
            detailLabel.handleCustomTap(for: custom) { [weak self] tagName in
                if let self = self,
                   let tag = self.viewModel.getTag(from: tagName),
                   let logList = self.instantiateInitialView(name: StoryboardName.logList) as? LogListViewController {
                    logList.setup(sectionType: .tags, tagList: self.viewModel.tagList, tag: tag)
                    self.navigationController?.pushViewController(logList, animated: true)
                }
            }
        }
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateLogDetail(_:)),
                                               name: .updateLogDetail,
                                               object: nil)
    }
    
    @objc private func updateLogDetail(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let logDetail = userInfo[NotificationUserInfoKey.updatedLogDetail.rawValue] as? LogDetail else {
            return
        }
        viewModel.setup(logDetail: logDetail, tagList: viewModel.tagList)
        setup()
    }
    
    @IBAction func onClickDate() {
        guard let logDetail = viewModel.logDetail else { return }
        guard let navi = instantiateInitialView(name: .updateDate) as? UINavigationController,
              let updateDate = navi.viewControllers.first as? UpdateDateViewController else { return }
        updateDate.setup(logDetail: logDetail)
        self.present(navi, animated: true)
    }

    //編集ボタンのタップで「viewModel.logDetail」の内容をインスタンス化した編集ビューコントローラーを全画面表示
    @IBAction func onClickEdit() {
        guard let logDetail = viewModel.logDetail else { return }
        guard let navi = instantiateInitialView(name: .updateText) as? UINavigationController,
              let updateText = navi.viewControllers.first as? UpdateTextViewController else { return }
        navi.modalPresentationStyle = .fullScreen
        updateText.setup(logDetail: logDetail)
        self.present(navi, animated: true)
    }
    
    @IBAction func exportTextFile() {
        var actionList: [UIAlertAction] = []
        let exportType: ExportType = .edit
        EncodingType.allCases.forEach { value in
            actionList.append(UIAlertAction(
                title: value.exportTitle,
                style: .default,
                handler: { [weak self] _ in
                    self?.viewModel.writeFile(encoding: value)
                }
            ))
        }
        presentActionSheet(
            title: exportType.title,
            message: exportType.message,
            actionList: actionList,
            isShowCancel: true
        )
    }

}

//RxSwiftを使用してデータのサブスクリプション（購読）を設定

extension EditViewController {
    private func setupSubscription() {
        viewModel.isLoading.main
            .subscribe(onNext: { isLoading in
                KRProgressHUD.showOrDismiss(isLoading: isLoading)
            }).disposed(by: disposeBag)
        
        viewModel.completedWrite.main
            .subscribe(onNext: { [weak self] url in
                let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                self?.present(activity, animated: true)
            }).disposed(by: disposeBag)
        
        viewModel.errorMessage.main
            .subscribe(onNext: { [weak self] message in
                self?.presentAlert(message: message)
            }).disposed(by: disposeBag)
    }
}
