//
//  SelectTimeViewController.swift
//  LifeLogApp
//
//  Created by ShinUnuma on 2021/07/10.
//

import UIKit
import FloatingPanel
import ReSwift

class SelectTimeViewController: UIViewController {
    @IBOutlet private weak var datePicker: UIDatePicker!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var doneButton: UIButton!
    
    private var floatingController: FloatingPanelController?
    private let viewModel = SelectTimeViewModel()
    static let height: CGFloat = 300

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        let localize = String.localize
        cancelButton.setTitle(localize.allLog.cancel, for: .normal)
        doneButton.setTitle(localize.changeDate.done, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainStore.subscribe(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mainStore.unsubscribe(self)
    }
    
    func setup(createDate: Date) {
        viewModel.setup(createDate: createDate)
    }
    
    private func setup() {
        titleLabel.text = viewModel.createDay
        datePicker.date = viewModel.createDate
    }

    @IBAction private func onClickCancel() {
        dismiss(animated: true)
    }
    
    @IBAction private func onClickDone() {
        let createTime = viewModel.timeOnly(date: datePicker.date)
        let userInfo = [NotificationUserInfoKey.updatedCreateTime.rawValue: createTime]
        NotificationCenter.default.post(name: .updateCreateTime,
                                        object: nil,
                                        userInfo: userInfo)
        dismiss(animated: true)
    }
}

extension SelectTimeViewController: StoreSubscriber {
    func newState(state: StringLocalizable) {
        cancelButton.setTitle(state.allLog.cancel, for: .normal)
        doneButton.setTitle(state.changeDate.done, for: .normal)
    }
}

extension SelectTimeViewController: FloatingPanelControllerDelegate {
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout {
        floatingController = vc
        return RecorderPanelLayout()
    }
    
    func floatingPanelDidChangePosition(_ vc: FloatingPanelController) {
        switch vc.state {
        case .hidden:
            break
        default:
            break
        }
    }
}

class RecorderPanelLayout: FloatingPanelLayout {
    let position: FloatingPanelPosition = .bottom
    let initialState: FloatingPanelState = .half
    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        return [
            .half: FloatingPanelLayoutAnchor(absoluteInset: SelectTimeViewController.height, edge: .bottom, referenceGuide: .safeArea)
        ]
    }
    
    func backdropAlpha(for state: FloatingPanelState) -> CGFloat {
        return 0.3
    }
}
