//
//  MainViewController.swift
//  LifeLogApp
//
//  Created by ShinUnuma on 2021/07/05.
//

import UIKit
import RxSwift
import KRProgressHUD
import AudioToolbox
import ReSwift

class MainViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.topPaddingZero()
        }
    }
    @IBOutlet private weak var inputButton: UIButton! {
        didSet {
            inputButton.backgroundColor = .clear
            inputButton.layer.cornerRadius = 25
            inputButton.layer.backgroundColor = inputButton.tintColor.cgColor
        }
    }
    @IBOutlet private weak var inputTextView: UIView! {
        didSet {
            inputTextView.alpha = 0
        }
    }
    @IBOutlet private weak var inputField: UITextView! {
        didSet {
            inputField.add(borderWidth: 1, radius: 5, color: UIColor.lightGray)
            inputField.delegate = self
            let contentSize = inputField.contentSize
            defaultInputSize = contentSize
        }
    }
    @IBOutlet private weak var saveButton: UIButton!
    @IBOutlet private weak var placeHolder: UILabel! {
        didSet { placeHolder.isHidden = false }
    }
    @IBOutlet private weak var inputFieldHeight: NSLayoutConstraint!
    @IBOutlet private weak var tableViewBottom: NSLayoutConstraint!
    private let viewModel = MainViewModel()
    private let disposeBag = DisposeBag()
    private let fieldTextHeight: CGFloat = 35
    private let addTextHeight: CGFloat = 20
    private var defaultInputSize: CGSize = .zero
    private let lineHeight: CGFloat = 20
    private var keyboardState: KeyboardState = .didHidden
    private var tagListState: TagListState = .hidden
    private var isOpenInputView = false
    private var openHeight: CGFloat = 0
    private var hiddenHeight: CGFloat {
        return inputTextView.frame.height
    }

    //ページ読み込み時の初期表示処理もろもろ
// String.localize.menuからタイトルを設定
// String.localize.menu.newLog の値を使用して、プレースホルダ内のテキストを設定
// String.localize.allLog.cancel値からUISearchBar内のUIBarButtonItemのタイトル設定
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubscription()
        setup()
        let localize = String.localize.menu
        navigationItem.title = localize.title
        placeHolder.text = localize.newLog
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).title = String.localize.allLog.cancel
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchAll()
        mainStore.subscribe(self)
        if let url = CustomURL.url, CustomURL.isImportExtension {
            UIViewController.presentImportFileViewController(url: url)
            CustomURL.url = nil
        }
    }
    
    //ビューコントローラのビューが画面から表示されなくなる直前に呼び出されるメソッド
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mainStore.unsubscribe(self)
        self.view.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func setup() {
        tableView.tableFooterView = UIView()
        navigationItem.backButtonTitle = ""
        //NotificationCenter.default.addObserver(self, selector: #selector(reloadLogList), name: .reloadTop, object: nil)
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillHidden), name: UIResponder.keyboardWillHideNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardDidHidden), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    //指定されたパラメータに基づいてログリストの表示と遷移!
    private func pushLogList(sectionType: MainSectionType, tag: Tag? = nil) {
        if let logList = instantiateInitialView(name: StoryboardName.logList) as? LogListViewController {
            logList.setup(sectionType: sectionType, tagList: viewModel.tagList, tag: tag)
            self.navigationController?.pushViewController(logList, animated: true)
        }
    }
    
    //入力ビュー（input view）の開閉時アニメ
    //
    private func animateOpenCloseInputView(isOpen: Bool) {
        tableViewBottom.constant = isOpen ? hiddenHeight : 0
        let buttonAlpha: CGFloat = isOpen ? 0 : 1
        let inputViewAlpha: CGFloat = isOpen ? 1 : 0
        inputButton.isEnabled = false
        if !isOpen {
            inputButton.isHidden = false
            inputButton.alpha = 0
        }
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.inputButton.alpha = buttonAlpha
            self?.inputTextView?.alpha = inputViewAlpha
            self?.view.layoutIfNeeded()
        }) { [weak self] finish in
            self?.inputButton.isHidden = isOpen
            self?.inputButton.isEnabled = true
        }
    }
    
    private func animateKeyboard(height: CGFloat) {
        if tableViewBottom.constant == height { return }
        tableViewBottom.constant = height
        inputTextView?.alpha = height == 0 ? 0 : 1
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            options: .curveEaseOut,
            animations: { [weak self] in
                self?.view.layoutIfNeeded()
            }
        )
    }
   
    //入力ボタン（inputbutton）のフェードイン・フェードアウトのアニメを行う
    private func animateFadeInOutInputButton(isHidden: Bool) {
        let alpha: CGFloat = isHidden ? 0 : 1
        if !isHidden {
            inputButton.isHidden = false
            inputButton.alpha = 0
        }
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.inputButton.alpha = alpha
        }) { [weak self] finish in
            self?.inputButton.isHidden = isHidden
        }
    }
    
    private func pushCalendar(sectionType: MainSectionType) {
        if let calendar = instantiateInitialView(name: StoryboardName.calendar) as? CalendarViewController {
            calendar.setup(tagList: viewModel.tagList, isSelectToday: true)
            self.navigationController?.pushViewController(calendar, animated: true)
        }
    }
    
    private func showConfirmExportAlert() {
        var actionList: [UIAlertAction] = []
        let exportType: ExportType = .all
        EncodingType.allCases.forEach { value in
            let action = UIAlertAction(
                title: value.exportTitle,
                style: .default) { [weak self] _ in
                    self?.viewModel.writeAllLogs(encoding: value)
                }
            actionList.append(action)
        }
        presentActionSheet(
            title: exportType.title,
            message: exportType.message,
            actionList: actionList,
            isShowCancel: true
        )
    }
    
    private func onClickCloseInputView() {
        if !isOpenInputView { return }
        isOpenInputView = false
        animateOpenCloseInputView(isOpen: isOpenInputView)
        keyboardState = .tapClose
        inputField.resignFirstResponder()
    }
    
    private func presentSelectTagSheet() {
        if viewModel.tagList.isEmpty { return }
        let actionList = viewModel.tagList.compactMap { tag in
            UIAlertAction(title: tag.name, style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.inputField.text.append(" \(tag.name)")
                self.placeHolder.isHidden = true
                self.tagListState = .hidden
            }
        }
        presentActionSheet(actionList: actionList) { [weak self] _ in
            guard let self = self else { return }
            self.tagListState = .hidden
        }
    }
    
    private func closeInputField() {
        inputField.text = ""
        inputFieldHeight.constant = fieldTextHeight
        placeHolder.isHidden = false
        onClickCloseInputView()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        let height = keyboardSize.height + hiddenHeight - view.safeAreaInsets.bottom
        openHeight = height
        animateKeyboard(height: height)
    }
    
    @objc func keyboardWillHidden(notification: NSNotification) {
        animateKeyboard(height: 0)
    }
    
    @objc func keyboardDidHidden(notification: NSNotification) {
        keyboardState = .didHidden
    }
    
    @objc func reloadLogList(notification: Notification) {
        viewModel.fetchAll()
    }
    
    @IBAction private func onClickOpenInputView() {
        if isOpenInputView { return }
        isOpenInputView = true
        animateOpenCloseInputView(isOpen: isOpenInputView)
    }
    
    @IBAction private func onClickSettings() {
        guard let settings = instantiateInitialView(name: .settings) else { return }
        self.present(settings, animated: true)
    }

    @IBAction private func onClickAllExport() {
        showConfirmExportAlert()
    }
    
    @IBAction func onClickSave() {
        guard let text = inputField.text else { return }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            closeInputField()
        } else {
            viewModel.isEnableSave.onNext(false)
            viewModel.create(text: text)
        }
    }
    
    @IBAction func onClickTags() {
        tagListState = keyboardState == .willShowByInputText ? .closeKeybordAndShow : .show
        if viewModel.tagList.isEmpty {
            AudioServicesPlaySystemSound(1519)
            inputField.text.append(" #")
            placeHolder.isHidden = true
        } else {
            presentSelectTagSheet()
        }
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.tags.isEmpty ? MainSectionType.allCases.count - 1 : MainSectionType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if MainSectionType(rawValue: section) == MainSectionType.tags {
            return viewModel.tagCount
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return MainSectionType.allCases[section].headerTitle
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
       return " "
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.sectionBg
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = UIColor.sectionHeaderLabel
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.sectionBg
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = UIColor.sectionHeaderLabel
        }
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sectionType = MainSectionType(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MainListCell.identifier, for: indexPath) as? MainListCell else {
            return UITableViewCell()
        }
        switch sectionType {
        case .all, .calendar:
            cell.setup(sectionType: sectionType, logCount: viewModel.logCount)
        case .tags:
            if let info = viewModel.tagInfo(index: indexPath.row) {
                cell.setupTag(sectionType: sectionType, info: info)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let sectionType = MainSectionType(rawValue: indexPath.section) else { return }
        closeInputField()
        switch sectionType {
        case .calendar:
            pushCalendar(sectionType: sectionType)
        case .all:
            pushLogList(sectionType: sectionType)
        case .tags:
            guard let info = viewModel.tagInfo(index: indexPath.row) else { return }
            pushLogList(sectionType: sectionType, tag: info.tag)
        }
    }
}

extension MainViewController: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        keyboardState = .willShowByInputText
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        var count = getNumberOfLines(in: textView)
        if count < 1 {
            count = 1
        } else if count > 5 {
            count = 5
        }
        let height = fieldTextHeight + addTextHeight * CGFloat(count-1)
        inputFieldHeight.constant = height
        placeHolder.isHidden = !textView.text.isEmpty
        tableViewBottom.constant = openHeight + addTextHeight * CGFloat(count-1)
    }
    
    private func getNumberOfLines(in textView: UITextView) -> Int {
        let contentHeight = textView.contentSize.height
        if defaultInputSize.height < contentHeight {
            let height = contentHeight - defaultInputSize.height
            return Int(height / lineHeight) + 1
        }
        return 1
    }
}

extension MainViewController: StoreSubscriber {
    func newState(state: StringLocalizable) {
        navigationItem.title = state.menu.title
        placeHolder.text = state.menu.newLog
        tableView.reloadData()
    }
}

extension MainViewController {
    private func setupSubscription() {
        viewModel.isLoading.main
            .subscribe(onNext: { isLoading in
                KRProgressHUD.showOrDismiss(isLoading: isLoading)
            }).disposed(by: disposeBag)
        
        viewModel.reloadData.main
            .subscribe(onNext: { [weak self] in
                self?.tableView.reloadData()
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
        
        viewModel.isEnableSave.main
            .subscribe(onNext: { [weak self] isEnable in
                self?.saveButton.isEnabled = isEnable
            }).disposed(by: disposeBag)
        
        viewModel.completeCreated.main
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                AudioServicesPlaySystemSound(1519)
                self.closeInputField()
            }).disposed(by: disposeBag)
    }
}

class MainListCell: UITableViewCell {
    @IBOutlet private weak var icon: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var countLabel: UILabel!
    static let identifier = "MainListCell"
    static let height: CGFloat = 50
    
    func setup(sectionType: MainSectionType, logCount: Int) {
        icon.image = sectionType.icon
        titleLabel.text = sectionType.labelTitle
        countLabel.isHidden = sectionType == .calendar
        countLabel.text = "(\(logCount))"
    }
    
    func setupTag(sectionType: MainSectionType, info: TagInfo) {
        icon.image = sectionType.icon
        titleLabel.text = info.tag.name.replacingOccurrences(of: "#", with: "")
        countLabel.isHidden = false
        countLabel.text = "(\(info.count))"
    }
}

enum MainSectionType: Int, CaseIterable {
    case calendar = 0
    case all
    case tags
    
    var headerTitle: String {
        switch self {
        case .calendar: return " "
        case .all: return " "
        case .tags: return String.localize.menu.tags
        }
    }
    
    var labelTitle: String? {
        switch self {
        case .calendar: return String.localize.menu.calendar
        case .all: return String.localize.menu.allLog
        case .tags: return String.localize.menu.tags
        }
    }
    
    var icon: UIImage {
        switch self {
        case .all: return UIImage(named: DarkModeHelper.isDarkMode ? "section_all_d" : "section_all")!
        case .calendar: return UIImage(named: DarkModeHelper.isDarkMode ? "section_calendar_d" : "section_calendar")!
        case .tags: return UIImage(named: "section_tags")!
        }
    }
}
