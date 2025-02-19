//
//  ExportViewController.swift
//  LifeLogApp
//
//  Created by ShinUnuma on 2021/07/13.
//

import UIKit
import FloatingPanel
import KRProgressHUD
import RxSwift
import ReSwift

class ExportViewController: UIViewController {
    @IBOutlet private weak var unicodeButton: UIButton!
    @IBOutlet private weak var rangeType: UISegmentedControl!
    @IBOutlet private weak var selectDateView: UIView!
    @IBOutlet private weak var descriptionView: UIView!
    @IBOutlet private weak var startDatePicker: UIDatePicker!
    @IBOutlet private weak var endDatePicker: UIDatePicker!
    @IBOutlet private weak var uniCodeLabel: UILabel!
    @IBOutlet private weak var rangeLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var exportButton: UIButton!
    @IBOutlet private weak var aboutUnicodeButton: UIButton!
    
    private var floatingController: FloatingPanelController?
    private let viewModel = ExportViewModel()
    private let disposeBag = DisposeBag()
    var selectedEncodingType: ((EncodingType) -> Void)? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubscription()
        setup()
        viewModel.setup()
        updateLanguage(localize: String.localize)
    }
    
    private func setup() {
        let info = viewModel.initStartAndEnd
        startDatePicker.date = info.start
        endDatePicker.date = info.end
        rangeType.addTarget(self, action: #selector(changedRangeType), for: .valueChanged)
        startDatePicker.addTarget(self, action: #selector(changeStartDate(_:)), for: .valueChanged)
        endDatePicker.addTarget(self, action: #selector(changeEndDate(_:)), for: .valueChanged)
    }
    
    private func updateLanguage(localize: StringLocalizable) {
        navigationItem.title = localize.settings.exportTitle
        uniCodeLabel.text = localize.settings.unicode
        rangeLabel.text = localize.settings.exportRange
        descriptionLabel.text = localize.settings.rangeMessage
        rangeType.setTitle(localize.settings.dateRange, forSegmentAt: 0)
        rangeType.setTitle(localize.settings.allRange, forSegmentAt: 1)
        let locale = Locale(identifier: LanguageType.current.locale)
        startDatePicker.locale = locale
        endDatePicker.locale = locale
        exportButton.setTitle(localize.settings.exportTitle, for: .normal)
        aboutUnicodeButton.setTitle(localize.settings.aboutUnicodeTitle, for: .normal)
    }
    
    @objc func changedRangeType(_ segment: UISegmentedControl) {
        guard let rangeType = RangeType(rawValue: segment.selectedSegmentIndex) else {
            return
        }
        switch rangeType {
        case .date:
            selectDateView.isHidden = false
            descriptionView.isHidden = true
        case .all:
            selectDateView.isHidden = true
            descriptionView.isHidden = false
        }
        viewModel.update(rangeType: rangeType)
    }
    
    @objc func changeStartDate(_ datePicker: UIDatePicker) {
        viewModel.update(start: datePicker.date)
    }
    
    @objc func changeEndDate(_ datePicker: UIDatePicker) {
        viewModel.update(end: datePicker.date)
    }
    
    @IBAction func onClickUnicode() {
        let actionList =  EncodingType.allCases.map { type in
            return UIAlertAction(
                title: type.exportTitle,
                style: .default) { [weak self] _ in
                self?.viewModel.update(encodingType: type)
                self?.selectedEncodingType?(type)
            }
        }
        presentActionSheet(actionList: actionList)
    }
    
    @IBAction func onClickExport() {
        let actionList = ExportFileType.allCases.map { type in
            return UIAlertAction(title: type.title, style: .default) { [weak self] _ in
                guard let `self` = self else { return }
                switch type {
                case .csv:
                    self.viewModel.update(start: self.startDatePicker.date, end: self.endDatePicker.date)
                    self.viewModel.exportCSVFile().disposed(by: self.disposeBag)
                case .backup:
                    self.viewModel.exportBackupFile().disposed(by: self.disposeBag)
                }
            }
        }
        presentActionSheet(actionList: actionList)
    }
    
    @IBAction private func onClickAboutUnicode() {
        let alert = UIAlertController(title: String.localize.settings.aboutUnicodeTitle, message: "", preferredStyle: .alert)
        let negative = UIAlertAction(title: AlertButton.close.title, style: .cancel)
        alert.addAction(negative)
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .left
        let attributes1: [NSAttributedString.Key : Any] = [
            .font: UIFont.systemFont(ofSize: 14.0, weight: .regular),
            .paragraphStyle: paragraph
        ]
        let attributes2: [NSAttributedString.Key : Any] = [
            .font: UIFont.systemFont(ofSize: 15.0, weight: .medium),
            .foregroundColor: UIColor.tagColor,
            .paragraphStyle: paragraph
        ]
        let attributes3: [NSAttributedString.Key : Any] = [
            .font: UIFont.systemFont(ofSize: 13.0, weight: .regular),
            .paragraphStyle: paragraph
        ]
        let message = NSMutableAttributedString()
        let stringList: [String] = [
            "\n\(String.localize.settings.aboutUnicodeMessge)\n\n",
            "\(EncodingType.utf8Bom.selectTitle)\n",
            "\(String.localize.settings.aboutUtf8BomMessage)\n\n",
            "\(EncodingType.utf8.selectTitle)\n",
            "\(String.localize.settings.aboutUtf8Message)\n\n",
            "\(EncodingType.shitjis.selectTitle)\n",
            "\(String.localize.settings.aboutShiftJisMessage)\n",
            "\(EncodingType.big5.selectTitle)\n",
            "\(String.localize.settings.aboutBig5Message)\n",
            "\(EncodingType.gb2312.selectTitle)\n",
            "\(String.localize.settings.aboutGB2312Message)\n",
        ]
        let attributes: [[NSAttributedString.Key : Any]] = [
            attributes1,
            attributes2,
            attributes3,
            attributes2,
            attributes3,
            attributes2,
            attributes3,
            attributes2,
            attributes3,
            attributes2,
            attributes3,
        ]
        stringList.enumerated().forEach { index, value in
            message.append(
                NSAttributedString(
                    string: value,
                    attributes: attributes[index]
                )
            )
        }
        alert.setValue(message, forKey: "attributedMessage")
        self.present(alert, animated: true)
    }
}

extension ExportViewController: StoreSubscriber {
    func newState(state: StringLocalizable) {
        updateLanguage(localize: state)
    }
}

extension ExportViewController {
    private func setupSubscription() {
        viewModel.isLoading.main
            .subscribe(onNext: { isLoading in
                KRProgressHUD.showOrDismiss(isLoading: isLoading)
            }).disposed(by: disposeBag)
        
        viewModel.completedExport.main
            .subscribe(onNext: { [weak self] url in
                let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                self?.present(activity, animated: true)
            }).disposed(by: disposeBag)
        
        viewModel.errorMessage.main
            .subscribe(onNext: { [weak self] message in
                self?.presentAlert(message: message)
            }).disposed(by: disposeBag)
        
        viewModel.resultCountZero.main
            .subscribe(onNext: { [weak self] in
                self?.presentAlert(message: String.localize.settings.outOfRangeMessage)
            }).disposed(by: disposeBag)
        
        viewModel.setupEncodingType.main
            .subscribe(onNext: { [weak self] type in
                self?.unicodeButton.setTitle(type.selectTitle, for: .normal)
            }).disposed(by: disposeBag)
        
        viewModel.setupRangeType.main
            .subscribe(onNext: { [weak self] type in
                self?.rangeType.selectedSegmentIndex = type.rawValue
                switch type {
                case .date:
                    self?.selectDateView.isHidden = false
                    self?.descriptionView.isHidden = true
                case .all:
                    self?.selectDateView.isHidden = true
                    self?.descriptionView.isHidden = false
                }
            }).disposed(by: disposeBag)
        
        viewModel.setupRangeDate.main
            .subscribe(onNext: { [weak self] info in
                self?.startDatePicker.date = info.start
                self?.endDatePicker.date = info.end
        }).disposed(by: disposeBag)
        
    }
}
