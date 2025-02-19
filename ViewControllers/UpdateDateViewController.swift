//
//  UpdateDateViewController.swift
//  LifeLogApp
//
//  Created by ShinUnuma on 2021/07/09.
//

import UIKit
import RxSwift
import FSCalendar
import KRProgressHUD
import FloatingPanel
import ReSwift

class UpdateDateViewController: UIViewController {
    @IBOutlet private weak var calendarView: FSCalendar! {
        didSet {
            calendarView.delegate = self
            calendarView.dataSource = self
            calendarView.locale = Locale(identifier: LanguageType.current.locale)
            calendarView.appearance.headerDateFormat = DateFormat().yyyyMM
        }
    }
    @IBOutlet private weak var createTimeLabel: UILabel!
    @IBOutlet private weak var navigationTitle: UINavigationItem!
    @IBOutlet private weak var cancelButton: UIBarButtonItem!
    @IBOutlet private weak var doneButton: UIBarButtonItem!
    @IBOutlet private weak var startLabel: UILabel!
    @IBOutlet private weak var currentTimeLabel: UIButton!
    
    private let viewModel = UpdateDateViewModel()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubscription()
        viewModel.reload.onNext(())
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateCreateTime(_:)),
                                               name: .updateCreateTime,
                                               object: nil)
        let localize = String.localize
        navigationTitle.title = localize.changeDate.title
        cancelButton.title = localize.allLog.cancel
        doneButton.title = localize.changeDate.done
        startLabel.text = localize.changeDate.fromDate
        currentTimeLabel.setTitle(localize.changeDate.setCurrent, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchLog()
        mainStore.subscribe(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mainStore.unsubscribe(self)
    }
    
    func setup(logDetail: LogDetail) {
        viewModel.setup(logDetail: logDetail)
    }
    
    @objc private func updateCreateTime(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let createdTime = userInfo[NotificationUserInfoKey.updatedCreateTime.rawValue] as? String else {
            return
        }
        viewModel.update(createTime: createdTime)
    }

    @IBAction func onClickCancel() {
        self.dismiss(animated: true)
    }
    
    @IBAction func onClickDone() {
        if viewModel.isNoChange() {
            dismiss(animated: true)
        } else {
            viewModel.updateLogDetail()
        }
    }
    
    @IBAction func onClickStartTime() {
        guard let selectTime = instantiateInitialView(name: .selectTime) as? SelectTimeViewController else { return }
        selectTime.setup(createDate: viewModel.createdDate)
        let floatingPanel = FloatingPanelController(delegate: selectTime)
        let appearance = SurfaceAppearance()
        appearance.cornerRadius = 8.0
        floatingPanel.surfaceView.appearance = appearance
        floatingPanel.set(contentViewController: selectTime)
        floatingPanel.isRemovalInteractionEnabled = true
        self.present(floatingPanel, animated: true)
    }
    
    @IBAction func onClickSetNow() {
        viewModel.setNowDate()
    }
}

extension UpdateDateViewController: StoreSubscriber {
    func newState(state: StringLocalizable) {
        navigationTitle.title = state.changeDate.title
        cancelButton.title = state.allLog.cancel
        doneButton.title = state.changeDate.done
        startLabel.text = state.changeDate.fromDate
    }
}

extension UpdateDateViewController: FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        viewModel.update(createdDate: date)
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        viewModel.changedPage(date: calendar.currentPage)
    }
}

extension UpdateDateViewController: FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return viewModel.eventCount(date: date)
    }
}

extension UpdateDateViewController {
    private func setupSubscription() {
        viewModel.isLoading.main
            .subscribe(onNext: { isLoading in
                KRProgressHUD.showOrDismiss(isLoading: isLoading)
            }).disposed(by: disposeBag)
        
        viewModel.reload.main
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.calendarView.select(self.viewModel.createdDate, scrollToDate: true)
                self.createTimeLabel.text = self.viewModel.createTime
            }).disposed(by: disposeBag)
        
        viewModel.completeUpdate.main
            .subscribe(onNext: { [weak self] logDetail in
                let userInfo = [NotificationUserInfoKey.updatedLogDetail.rawValue: logDetail]
                NotificationCenter.default.post(name: .updateLogDetail,
                                                object: nil,
                                                userInfo: userInfo)
                self?.dismiss(animated: true)
            }).disposed(by: disposeBag)
        
        viewModel.errorMessage.main
            .subscribe(onNext: { [weak self] message in
                self?.presentAlert(message: message)
            }).disposed(by: disposeBag)
    }
}
