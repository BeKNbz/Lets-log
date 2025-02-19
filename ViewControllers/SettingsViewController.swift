//
//  SettingsViewController.swift
//  LifeLogApp
//
//  Created by ShinUnuma on 2022/01/29.
//

import UIKit
import RxSwift
import ReSwift
import MobileCoreServices
import KRProgressHUD

enum SettingSection: Int, CaseIterable {
    case export
    case `import`
    case localize
    case etc
    
    var title: String {
        switch self {
        case .export: return String.localize.settings.exportTitle
        case .`import`: return String.localize.settings.importTitle
        case .localize: return String.localize.settings.selectLanguage
        case .etc: return " "
        }
    }
    
    var rowSize: Int {
        switch self {
        case .etc: return SettingEtcType.allCases.count
        default: return 1
        }
    }
}

enum SettingEtcType: Int, CaseIterable {
    case privacyPolicy
    case termOfService
    
    var title: String {
        switch self {
        case .privacyPolicy: return String.localize.settings.privacyPolicy
        case .termOfService: return String.localize.settings.termOfService
        }
    }
}

enum ImportDocumentType: CaseIterable {
    case custom
    case csv
    
    var uti: String {
        switch self {
        case .custom: return "com.sunuma.product.LifeLogApp"
        case .csv: return "com.sunuma.product.LifeLogApp.csv"
        }
    }
    
    var extensionValue: String {
        switch self {
        case .custom: return "letslog"
        case .csv: return "csv"
        }
    }
    
    var selectTitle: String {
        switch self {
        case .custom: return String.localize.settings.importTitleCustom
        case .csv: return String.localize.settings.importTitleCsv
        }
    }
}

class SettingsViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.topPaddingZero()
        }
    }
    @IBOutlet private weak var navigationTitle: UINavigationItem!
    private let sections = SettingSection.allCases
    private let viewModel = SettingsViewModel()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubscription()
        navigationController?.navigationBar.barTintColor = .settingBlack
        navigationTitle.title = String.localize.settings.title
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainStore.subscribe(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mainStore.unsubscribe(self)
    }
    
    private func showSelectLocalizeLanguage() {
        let actionList = LanguageType.allCases.map { type in
            return UIAlertAction(title: type.title, style: .default) { [weak self] _ in
                self?.viewModel.save(languageType: type)
            }
        }
        presentActionSheet(actionList: actionList)
    }
    
    private func showFileDocumentPicker(type: ImportDocumentType) {
        let picker = UIDocumentPickerViewController(
            documentTypes: [type.uti],
            in: .import
        )
        picker.delegate = self
        self.present(picker, animated: true)
    }
    
    private func showSelectDocumentTypeAlert() {
        let actionList: [UIAlertAction] = ImportDocumentType.allCases.map { type in
            UIAlertAction(
                title: type.selectTitle,
                style: .default
            ) { [weak self] _ in
                self?.showFileDocumentPicker(type: type)
            }
        }
        self.presentActionSheet(
            title: nil,
            message: String.localize.settings.importTypeMessage,
            actionList: actionList,
            isShowCancel: true
        )
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
    
    private func showConfirmCSVTypeAlert(urls: [URL]) {
        KRProgressHUD.dismiss() {
            DispatchQueue.main.async { [weak self] in
                let actionList: [UIAlertAction] = EncodingType.allCases.map { type in
                    UIAlertAction(title: type.selectTitle, style: .default) { [weak self] _ in
                        self?.viewModel.readCSVFile(urls: urls, type: type)
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
            negativeButton: .confirm
        )
    }
}

extension SettingsViewController: StoreSubscriber {
    func newState(state: StringLocalizable) {
        navigationTitle.title = state.settings.title
    }
}

extension SettingsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= tableView.sectionHeaderHeight && scrollView.contentOffset.y >= 0 {
            scrollView.contentInset = UIEdgeInsets(top: -scrollView.contentOffset.y, left: 0, bottom: 0, right: 0)
        } else if scrollView.contentOffset.y >= tableView.sectionHeaderHeight {
            scrollView.contentInset = UIEdgeInsets(top: -tableView.sectionHeaderHeight, left: 0, bottom: 0, right: 0)
        }
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let settingSection = SettingSection(rawValue: indexPath.section) else { return }
        switch settingSection {
        case .export:
            if let export = instantiateInitialView(name: .export) as? ExportViewController {
                export.selectedEncodingType = { [weak self] type in
                    self?.viewModel.update(encodingType: type)
                }
                navigationController?.pushViewController(export, animated: true)
            }
        case .`import`:
            showSelectDocumentTypeAlert()
        case .localize:
            showSelectLocalizeLanguage()
        case .etc:
            guard let etcType = SettingEtcType(rawValue: indexPath.row) else { return }
            switch etcType {
            case .privacyPolicy:
                break
            case .termOfService:
                break
            }
        }
    }
}

extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return " "
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.sectionBg
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = UIColor.sectionHeaderLabel
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections.indices.contains(section) ? sections[section].rowSize : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.identifier, for: indexPath) as? SettingsCell,
              let settingSection = SettingSection(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        switch settingSection {
        case .export:
            cell.setup(
                title: settingSection.title,
                secondary: viewModel.currentExport.selectTitle
            )
        case .`import`:
            cell.setup(title: settingSection.title)
        case .localize:
            cell.setup(
                title: settingSection.title,
                secondary: viewModel.currentLanguage.title
            )
        case .etc:
            if let title = SettingEtcType(rawValue: indexPath.row)?.title {
                cell.setup(title: title)
            }
        }
        return cell
    }
}

extension SettingsViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if !urls.isEmpty {
            viewModel.importFile(urls: urls)
        } else {
            viewModel.failedMessage.onNext(String.localize.backup.notFound)
        }
    }
}

extension SettingsViewController {
    private func setupSubscription() {
        viewModel.isLoading.main
            .subscribe(onNext: { isLoading in
                KRProgressHUD.showOrDismiss(isLoading: isLoading)
            }).disposed(by: disposeBag)
        viewModel.reloadTableData.main
            .subscribe(onNext: { [weak self] in
                self?.tableView.reloadData()
            }).disposed(by: disposeBag)
        viewModel.confirmSave.main
            .subscribe(onNext: { [weak self] in
                self?.showComfirmImportAlert()
            }).disposed(by: disposeBag)
        viewModel.confirmCSVType.main
            .subscribe(onNext: { [weak self] urls in
                self?.showConfirmCSVTypeAlert(urls: urls)
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

class SettingsCell: UITableViewCell {
    static let identifier = "SettingsCell"
    @IBOutlet private weak var titeLabel: UILabel!
    @IBOutlet private weak var secondaryLabel: UILabel!
    
    func setup(title: String, secondary: String? = nil) {
        titeLabel.text = title
        secondaryLabel.text = secondary
    }
}
