//
//  LogListViewController.swift
//  LifeLogApp
//
//  Created by ShinUnuma on 2021/07/05.
//

import UIKit
import RxSwift
import RxCocoa
import KRProgressHUD
import AudioToolbox
import ReSwift

class LogListViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.tableFooterView = UIView()
            tableView.keyboardDismissMode = .interactive
            tableView.topPaddingZero()
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
    @IBOutlet private weak var inputButton: UIButton! {
        didSet {
            inputButton.backgroundColor = .clear
            inputButton.layer.cornerRadius = 25
            inputButton.layer.backgroundColor = inputButton.tintColor.cgColor
        }
    }
    @IBOutlet private weak var exportButton: UIBarButtonItem!
    @IBOutlet private weak var inputTextView: UIView!
    @IBOutlet private weak var emptyView: UIView!
    @IBOutlet private weak var saveButton: UIButton!
    @IBOutlet private weak var searchExportButton: UIButton!
    @IBOutlet private weak var placeHolder: UILabel! {
        didSet { placeHolder.isHidden = false }
    }
    @IBOutlet private weak var inputFieldHeight: NSLayoutConstraint!
    @IBOutlet private weak var inputViewBottom: NSLayoutConstraint!
    
    private var searchController: UISearchController!
    private let viewModel = LogListViewModel()
    private let disposeBag = DisposeBag()
    private let fieldTextHeight: CGFloat = 35
    private let addTextHeight: CGFloat = 20
    private var keyboardState: KeyboardState = .didHidden
    private var tagListState: TagListState = .hidden
    private var defaultInputSize: CGSize = .zero
    private let lineHeight: CGFloat = 20
    private var isOpenInputView = false
    private var previousDate: Date? = nil
    private var hiddenHeight: CGFloat {
        return inputTextView.frame.height + self.view.safeAreaInsets.bottom
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubscription()
        setup()
        viewModel.fetchLogs()
        navigationItem.backButtonTitle = ""
        setupExportButton()
        placeHolder.text = String.localize.menu.newLog
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selected = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selected, animated: true)
        }
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
    
    private func setupExportButton() {
        if viewModel.isTypeTags {
            exportButton.isEnabled = true
            exportButton.tintColor = UIColor.tagColor
        } else {
            exportButton.isEnabled = false
            exportButton.tintColor = .clear
        }
    }
    
    func setup(sectionType: MainSectionType, tagList: [Tag], tag: Tag?) {
        viewModel.setup(sectionType: sectionType, tagList: tagList, tag: tag)
    }

    private func setup() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = String.localize.allLog.search
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        navigationItem.titleView = createNavigationTitleView()
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillHidden), name: UIResponder.keyboardWillHideNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardDidHidden), name: UIResponder.keyboardDidHideNotification, object: nil)
        center.addObserver(self, selector: #selector(updateLogDetail(_:)), name: .updateLogDetail, object: nil)
        searchController.searchBar.rx.text
            .orEmpty
            .skip(1)
            .debounce(.milliseconds(1000), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] keyword in
                self?.viewModel.search(keyword: keyword)
            }).disposed(by: disposeBag)
    }
    
    private func createNavigationTitleView() -> UIView? {
        let sectionType = viewModel.sectionType
        let navView = UIView()
        let label = UILabel()
        if let tag = viewModel.tag {
            label.text = tag.name.replacingOccurrences(of: "#", with: "")
            inputField.text = tag.name
            placeHolder.isHidden = true
        } else {
            label.text = sectionType.labelTitle
        }
        label.font = UIFont.boldSystemFont(ofSize: 17.0)
        label.sizeToFit()
        if let text = label.text, label.frame.width > (UIScreen.main.bounds.width - 50) {
            label.text = String(text.prefix(15)) + "…"
            label.sizeToFit()
        }
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
    
    private func inputTextAnimation(height: CGFloat) {
        if inputViewBottom.constant == height { return }
        inputViewBottom.constant = height
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       options: .curveEaseOut,
                       animations: { [weak self] in
                        self?.view.layoutIfNeeded()
                       })
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
    
    private func animateOpenCloseInputView(isOpen: Bool) {
        inputViewBottom.constant = isOpen ? 0 : hiddenHeight
        let alpha: CGFloat = isOpen ? 0 : 1
        inputButton.isEnabled = false
        if !isOpen {
            inputButton.isHidden = false
            inputButton.alpha = 0
        }
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.inputButton.alpha = alpha
            self?.view.layoutIfNeeded()
        }) { [weak self] finish in
            self?.inputButton.isHidden = isOpen
            self?.inputButton.isEnabled = true
        }
    }
    
    private func showConfirmDeleteAlert(indexPath: IndexPath) {
        guard let logDetail = viewModel.logDetail(indexPath: indexPath) else { return }
        self.presentAlert(title: nil,
                          message: String.localize.calendar.deleteMessage,
                          positiveButton: .delete,
                          negativeButton: .cancel,
                          positiveHandler: { [weak self] in
                            self?.viewModel.delete(logDetail: logDetail)
                          })
    }
    
    private func showConfirmSearchExportAlert() {
        if let text = searchController.searchBar.text, !text.isEmpty {
            var actionList: [UIAlertAction] = []
            let exportType: ExportType = .search
            EncodingType.allCases.forEach { value in
                actionList.append(UIAlertAction(
                    title: value.exportTitle,
                    style: .default,
                    handler: { [weak self] _ in
                        self?.viewModel.writeSearchLogs(keyword: text, encoding: value)
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
    
    private func showConfirmTagExportAlert() {
        if viewModel.isTypeTags, let tag = viewModel.tag {
            var actionList: [UIAlertAction] = []
            let exportType: ExportType = .tags
            EncodingType.allCases.forEach { value in
                actionList.append(UIAlertAction(
                    title: value.exportTitle,
                    style: .default,
                    handler: { [weak self] _ in
                        self?.viewModel.writeTagLogs(tag: tag, encoding: value)
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
    
    private func pushLogList(tagName: String) {
        if let tag = viewModel.getTag(from: tagName),
           let logList = instantiateInitialView(name: StoryboardName.logList) as? LogListViewController {
            logList.setup(sectionType: .tags, tagList: viewModel.tagList, tag: tag)
            self.navigationController?.pushViewController(logList, animated: true)
        }
    }
    
    private func animateUpdateCell(isNewSection: Bool) {
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            if isNewSection {
                self.tableView.insertSections(IndexSet(integer: 0), with: .automatic)
            }
            self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            self.tableView.endUpdates()
        }
    }
    
    private func onClickCloseInputView() {
        if !isOpenInputView { return }
        isOpenInputView = false
        animateOpenCloseInputView(isOpen: isOpenInputView)
        keyboardState = .tapClose
        inputField.resignFirstResponder()
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
        if keyboardState == .willShowBySearch {
            let height = keyboardSize.height - self.view.safeAreaInsets.bottom - inputTextView.frame.height
            inputTextAnimation(height: -height)
        } else {
            let height = keyboardSize.height - self.view.safeAreaInsets.bottom
            inputTextAnimation(height: -height)
        }
    }
    
    @objc func keyboardWillHidden(notification: NSNotification) {
        let height = tagListState == .closeKeybordAndShow || keyboardState == .tapClose ? hiddenHeight : 0
        inputTextAnimation(height: height)
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

    @IBAction private func onClickExport() {
        showConfirmTagExportAlert()
    }
    
    @IBAction private func onClickSearchExport() {
        showConfirmSearchExportAlert()
    }
}

extension LogListViewController: StoreSubscriber {
    func newState(state: StringLocalizable) {
        navigationItem.title = state.menu.title
    }
}

extension LogListViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = tableView.contentOffset.y
        let bottomOffset = tableView.contentSize.height - tableView.bounds.height
        if currentOffset >= bottomOffset && !viewModel.isProgress && !viewModel.isMax && keyboardState == .didHidden {
            viewModel.fetchLogs()
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        animateFadeInOutInputButton(isHidden: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        animateFadeInOutInputButton(isHidden: false)
    }
}

extension LogListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return LogListCell.sectionHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let logDetail = viewModel.logDetail(indexPath: indexPath) else { return }
        guard let edit = instantiateInitialView(name: StoryboardName.edit) as? EditViewController else { return }
        inputField.resignFirstResponder()
        edit.setup(logDetail: logDetail, tagList: viewModel.tagList)
        self.navigationController?.pushViewController(edit, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, handler in
            //self?.showConfirmDeleteAlert(indexPath: indexPath)
            guard let self = self, let logDetail = self.viewModel.logDetail(indexPath: indexPath) else { return }
            self.viewModel.delete(logDetail: logDetail)
            handler(true)
        }
        deleteAction.image = UIImage(named: "trash")
        deleteAction.backgroundColor = UIColor(red: 252/255, green: 49/255, blue: 88/255, alpha: 1)
        let swipeAction = UISwipeActionsConfiguration(actions:[deleteAction])
        swipeAction.performsFirstActionWithFullSwipe = false
        return swipeAction
    }
}

extension LogListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sectionCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.logCount(section: section)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.sectionTitle(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LogListCell.identifier, for: indexPath) as? LogListCell else {
            return UITableViewCell()
        }
        if let log = viewModel.logDetail(indexPath: indexPath) {
            cell.setup(log: log, keyword: viewModel.searchWord)
            cell.onTapHashTag = pushLogList
            previousDate = log.createdAt
        }
        return cell
    }
    
}

extension LogListViewController: UISearchControllerDelegate {
    func willPresentSearchController(_ searchController: UISearchController) {
        searchExportButton.isHidden = false
        searchExportButton.alpha = 0
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.searchExportButton.alpha = 1
        }, completion: { [weak self] finish in
            self?.searchExportButton.alpha = 1
        })
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.searchExportButton.alpha = 0
        }, completion: { [weak self] finish in
            self?.searchExportButton.alpha = 0
            self?.searchExportButton.isHidden = true
        })
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        viewModel.search(keyword: "")
    }
}

extension LogListViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        keyboardState = .willShowBySearch
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        keyboardState = .tapClose
        isOpenInputView = false
        animateOpenCloseInputView(isOpen: isOpenInputView)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        keyboardState = .tapClose
        isOpenInputView = false
        animateOpenCloseInputView(isOpen: isOpenInputView)
        if inputField.isFirstResponder {
            inputField.resignFirstResponder()
        }
    }
}

extension LogListViewController: UITextViewDelegate {
    
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

extension LogListViewController {
    private func setupSubscription() {
        viewModel.isLoading.main
            .subscribe(onNext: { isLoading in
                KRProgressHUD.showOrDismiss(isLoading: isLoading)
            }).disposed(by: disposeBag)
        
        viewModel.isEnableSave.main
            .subscribe(onNext: { [weak self] isEnable in
                self?.saveButton.isEnabled = isEnable
            }).disposed(by: disposeBag)
        
        viewModel.completedGetLogs.main
            .subscribe(onNext: { [weak self] isEmpty in
                guard let self = self else { return }
                self.emptyView.isHidden = !isEmpty
                self.tableView.isHidden = isEmpty
                if !isEmpty {
                    self.tableView.reloadData()
                }
            }).disposed(by: disposeBag)
        
        viewModel.searchResult.main
            .subscribe(onNext: { [weak self] isEmpty in
                guard let self = self else { return }
                self.emptyView.isHidden = !isEmpty
                self.tableView.isHidden = isEmpty
                if !isEmpty {
                    self.tableView.reloadData()
                }
            }).disposed(by: disposeBag)
        
        viewModel.completedCreate.main
            .subscribe(onNext: { [weak self] isNewSection in
                guard let self = self else { return }
                AudioServicesPlaySystemSound(1519)
                self.closeInputField()
                if self.tableView.isHidden {
                    self.emptyView.isHidden = true
                    self.tableView.isHidden = false
                }
                self.tableView.reloadData()
                //self.animateUpdateCell(isNewSection: isNewSection)
            }).disposed(by: disposeBag)
        
        viewModel.completedDelete.main
            .subscribe(onNext: { [weak self] isEmpty in
                self?.emptyView.isHidden = !isEmpty
                self?.tableView.isHidden = isEmpty
                self?.tableView.reloadData()
                NotificationCenter.default.post(name: .reloadTop, object: nil, userInfo: nil)
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

class LogListCell: UITableViewCell {
    @IBOutlet private weak var createLabel: UILabel!
    @IBOutlet private weak var textDetail: CustomActiveLabel! {
        didSet {
            textDetail.enabledTypes = [custom]
            textDetail.customColor[custom] = .tagColor
        }
    }
    static let identifier = "LogListCell"
    static let sectionHeight: CGFloat = 40
    let custom = CustomActiveType.custom(pattern: "#[^#\\s]*")
    var onTapHashTag: ((String) -> Void)? = nil
    
    func setup(log: LogDetail, keyword: String = "") {
        update(keyword: keyword)
        createLabel.text = log.createTime
        if log.text.isEmpty {
            textDetail.textColor = .emptyTextLabel
            textDetail.text = String.localize.editLog.emptyLog
        } else {
            textDetail.textColor = .textLabel
            textDetail.text = log.text
            textDetail.handleCustomTap(for: custom) { [weak self] tag in
                self?.onTapHashTag?(tag)
            }
        }
    }
    
    private func update(keyword: String) {
        if keyword.isEmpty {
            textDetail.enabledTypes = [custom]
            textDetail.customColor[custom] = .tagColor
        } else {
            let highlight = CustomActiveType.custom(pattern: keyword)
            textDetail.enabledTypes = [custom, highlight]
            textDetail.customColor[custom] = .tagColor
            textDetail.customColor[highlight] = .highlight
        }
    }
    
}

enum KeyboardState {
    case willShowByInputText
    case willShowBySearch
    case didHidden
    case tapClose
}

enum TagListState {
    case show
    case closeKeybordAndShow
    case hidden
}
