//
//  CalendarViewController.swift
//  LifeLogApp
//
//  Created by ShinUnuma on 2021/07/05.
//

import UIKit
import RxSwift
import FSCalendar
import KRProgressHUD
import AudioToolbox
import ReSwift

class CalendarViewController: UIViewController {
    @IBOutlet private weak var calendarView: FSCalendar! {
        didSet {
            calendarView.delegate = self
            calendarView.dataSource = self
            calendarView.locale = Locale(identifier: LanguageType.current.locale)
            calendarView.appearance.headerDateFormat = DateFormat().yyyyMM
        }
    }
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.tableFooterView = UIView()
            tableView.topPaddingZero()
        }
    }
    @IBOutlet private weak var emptyView: UIView!
    @IBOutlet private weak var emptyMessage: UILabel!
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
    @IBOutlet private weak var calendarTop: NSLayoutConstraint!
    private let viewModel = CalendarViewModel()
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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubscription()
        navigationItem.titleView = createNavigationTitleView()
        setupEventObserver()
        setupSwipeViewGesture()
        let localize = String.localize
        let message = localize.calendar.emptyMessage
        emptyMessage.text = String(format: message, viewModel.selectedDateLabel)
        placeHolder.text = localize.menu.newLog
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchLog()
        mainStore.subscribe(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mainStore.unsubscribe(self)
        self.view.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func setup(tagList: [Tag], isSelectToday: Bool) {
        viewModel.setup(tagList: tagList, isSelectToday: isSelectToday)
    }

    private func createNavigationTitleView() -> UIView? {
        let sectionType = MainSectionType.calendar
        let navView = UIView()
        let label = UILabel()
        label.text = sectionType.labelTitle
        label.font = UIFont.boldSystemFont(ofSize: 17.0)
        label.sizeToFit()
        label.center = navView.center
        label.textAlignment = .center
        let iconView = UIImageView()
        iconView.image = sectionType.icon
        var labelFrame = label.frame
        let iconSize = labelFrame.height
        labelFrame.origin.x = labelFrame.origin.x + iconSize * 0.5 + 5
        label.frame = labelFrame
        iconView.frame = CGRect(x: labelFrame.origin.x - iconSize - 5,
                                y: labelFrame.origin.y,
                                width: iconSize,
                                height: iconSize)
        iconView.contentMode = .scaleAspectFit
        navView.addSubview(label)
        navView.addSubview(iconView)
        return navView
    }
    
    private func setupEventObserver() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillHidden), name: UIResponder.keyboardWillHideNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardDidHidden), name: UIResponder.keyboardDidHideNotification, object: nil)
        center.addObserver(self, selector: #selector(updateLogDetail(_:)), name: .updateLogDetail, object: nil)
    }
    
    private func setupSwipeViewGesture() {
        var rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(_:)))
        rightSwipe.direction = .right
        emptyView.addGestureRecognizer(rightSwipe)
        rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(_:)))
        rightSwipe.direction = .right
        tableView.addGestureRecognizer(rightSwipe)
        var leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(_:)))
        leftSwipe.direction = .left
        emptyView.addGestureRecognizer(leftSwipe)
        leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(_:)))
        leftSwipe.direction = .left
        tableView.addGestureRecognizer(leftSwipe)
    }
    
    private func showConfirmDeleteAlert(indexPath: IndexPath) {
        self.presentAlert(title: nil,
                          message: String.localize.calendar.deleteMessage,
                          positiveButton: .delete,
                          negativeButton: .cancel,
                          positiveHandler: { [weak self] in
                            self?.viewModel.delete(indexPath: indexPath)
                          })
    }
    
    private func animateOpenCloseInputView(isOpen: Bool) {
        tableViewBottom.constant = isOpen ? hiddenHeight : 0
        calendarTop.constant = isOpen ? -hiddenHeight : 0
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
    
    private func pushLogList(tagName: String) {
        if let tag = viewModel.getTag(from: tagName),
           let logList = instantiateInitialView(name: StoryboardName.logList) as? LogListViewController {
            logList.setup(sectionType: .tags, tagList: viewModel.tagList, tag: tag)
            self.navigationController?.pushViewController(logList, animated: true)
        }
    }
    
    private func showConfirmExportAlert() {
        var actionList: [UIAlertAction] = []
        let exportType: ExportType = .calendar
        EncodingType.allCases.forEach { value in
            actionList.append(UIAlertAction(
                title: value.exportTitle,
                style: .default,
                handler: { [weak self] _ in
                    self?.viewModel.writeCalendarLogs(encoding: value)
                }
            ))
        }
        let message = String(format: exportType.message, viewModel.exportDateLabel)  
        presentActionSheet(
            title: exportType.title,
            message: message,
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
    
    @objc private func updateLogDetail(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let logDetail = userInfo[NotificationUserInfoKey.updatedLogDetail.rawValue] as? LogDetail else {
            return
        }
        viewModel.update(logDetail: logDetail)
    }
    
    @objc private func didSwipe(_ sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case .left:
            calendarView.setCurrentPage(viewModel.nextMonth, animated: true)
        case .right:
            calendarView.setCurrentPage(viewModel.previousMonth, animated: true)
        default: break
        }
    }
    
    @IBAction private func onClickExport() {
        showConfirmExportAlert()
    }
    
    @IBAction private func onClickOpenInputView() {
        if isOpenInputView { return }
        isOpenInputView = true
        animateOpenCloseInputView(isOpen: isOpenInputView)
    }
    
    @IBAction func onClickSave() {
        guard let text = inputField.text else { return }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            onClickCloseInputView()
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

extension CalendarViewController: StoreSubscriber {
    func newState(state: StringLocalizable) {
        navigationItem.title = state.menu.title
    }
}

extension CalendarViewController: FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        switch monthPosition {
        case .previous:
            calendarView.setCurrentPage(viewModel.previousMonth, animated: true)
            viewModel.changedPage(date: date)
        case .current:
            viewModel.update(selectedDate: date)
        case .next:
            calendarView.setCurrentPage(viewModel.nextMonth, animated: true)
            viewModel.changedPage(date: date)
        default:
            break
        }
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        viewModel.changedPage(date: calendar.currentPage)
        if keyboardState != .didHidden {
            onClickCloseInputView()
        }
    }
}

extension CalendarViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == tableView {
            animateFadeInOutInputButton(isHidden: true)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if !isOpenInputView {
            animateFadeInOutInputButton(isHidden: false)
        }
    }
    
}

extension CalendarViewController: FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return viewModel.eventCount(date: date)
    }
}

extension CalendarViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return LogListCell.sectionHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let logDetail = viewModel.logDetail(indexPath: indexPath) else { return }
        guard let edit = instantiateInitialView(name: StoryboardName.edit) as? EditViewController else { return }
        edit.setup(logDetail: logDetail, tagList: viewModel.tagList)
        self.navigationController?.pushViewController(edit, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, handler in
            self?.viewModel.delete(indexPath: indexPath)
            //self?.showConfirmDeleteAlert(indexPath: indexPath)
            handler(true)
        }
        deleteAction.image = UIImage(named: "trash")
        deleteAction.backgroundColor = UIColor(red: 252/255, green: 49/255, blue: 88/255, alpha: 1)
        let swipeAction = UISwipeActionsConfiguration(actions:[deleteAction])
        swipeAction.performsFirstActionWithFullSwipe = false
        return swipeAction
    }
}

extension CalendarViewController: UITextViewDelegate {
    
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

extension CalendarViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sectionCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.listCount(section: section)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.headerTitle(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LogListCell.identifier, for: indexPath) as? LogListCell else {
            return UITableViewCell()
        }
        if let log = viewModel.logDetail(indexPath: indexPath) {
            cell.setup(log: log)
            cell.onTapHashTag = pushLogList
        }
        return cell
    }
    
}

extension CalendarViewController {
    private func setupSubscription() {
        viewModel.isLoading.main
            .subscribe(onNext: { isLoading in
                KRProgressHUD.showOrDismiss(isLoading: isLoading)
            }).disposed(by: disposeBag)
        
        viewModel.updateCalendar.main
            .subscribe(onNext: { [weak self] isEmpty in
                guard let `self` = self else { return }
                self.emptyView.isHidden = !isEmpty
                self.tableView.isHidden = isEmpty
                self.calendarView.reloadData()
                self.tableView.reloadData()
                if isEmpty {
                    let message = String.localize.calendar.emptyMessage
                    self.emptyMessage.text = String(format: message, self.viewModel.selectedDateLabel)
                }
            }).disposed(by: disposeBag)
        
        viewModel.updateLogList.main
            .subscribe(onNext: { [weak self] isEmpty in
                guard let `self` = self else { return }
                self.emptyView.isHidden = !isEmpty
                self.tableView.isHidden = isEmpty
                self.tableView.reloadData()
                if isEmpty {
                    let message = String.localize.calendar.emptyMessage
                    self.emptyMessage.text = String(format: message, self.viewModel.selectedDateLabel)
                }
            }).disposed(by: disposeBag)
        
        viewModel.completedCreate.main
            .subscribe(onNext: { [weak self] isNewSection in
                guard let self = self else { return }
                AudioServicesPlaySystemSound(1519)
                self.inputField.text = ""
                self.inputFieldHeight.constant = self.fieldTextHeight
                if self.tableView.isHidden {
                    self.emptyView.isHidden = true
                    self.tableView.isHidden = false
                }
                self.tableView.reloadData()
                self.calendarView.reloadData()
                self.onClickCloseInputView()
            }).disposed(by: disposeBag)
        
        viewModel.completedDelete.main
            .subscribe(onNext: { [weak self] isEmpty in
                self?.emptyView.isHidden = !isEmpty
                self?.tableView.isHidden = isEmpty
                self?.tableView.reloadData()
                self?.calendarView.reloadData()
                NotificationCenter.default.post(name: .reloadTop, object: nil, userInfo: nil)
            }).disposed(by: disposeBag)
        
        viewModel.isEnableSave.main
            .subscribe(onNext: { [weak self] isEnable in
                self?.saveButton.isEnabled = isEnable
            }).disposed(by: disposeBag)
        
        viewModel.isUpdateLogList.main
            .subscribe(onNext: { [weak self] logDetail in
                guard let self = self else { return }
                if let logDetail = logDetail {
                    self.viewModel.updateLogList(logDetail: logDetail)
                } else {
                    AudioServicesPlaySystemSound(1519)
                    self.inputField.text = ""
                    self.inputFieldHeight.constant = self.fieldTextHeight
                }
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
