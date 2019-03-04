//
//  AttendViewController.swift
//  DDD
//
//  Created by ParkSungJoon on 28/02/2019.
//  Copyright © 2019 Gunter. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SVProgressHUD

class AttendViewController: UIViewController {

    @IBOutlet weak var numberTextField: UnderLineTextField!
    @IBOutlet weak var circleBackgroundImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var attendButton: UIButton!
    @IBOutlet weak var buttonBackgroundView: UIView!
    
    private var attendViewModel = AttendViewModel(attendService: AttendService())
    private weak var shadowView: UIView?
    private let disposeBag = DisposeBag()
    
    var userType: Int? {
        didSet {
            guard let userType = userType else { return }
            setupViewStyle(by: userType)
        }
    }
    var userId: Int? {
        didSet {
            guard let userId = self.userId else { return }
            self.userIdRelay.accept(userId)
        }
    }
    var userIdRelay: BehaviorRelay<Int> = BehaviorRelay(value: -1)
    var buttonFlagRelay: BehaviorRelay<Bool> = BehaviorRelay(value: true)
    var attendResponseData: AttendResponse?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRx()
        configureShadow(to: buttonBackgroundView)
    }
    
    private func setupRx() {
        attendViewModel.progressBinding
            .bind(to: SVProgressHUD.rx.isAnimating)
            .disposed(by: disposeBag)
        
        numberTextField.rx.text.orEmpty
            .bind(to: attendViewModel.number)
            .disposed(by: disposeBag)
        
        attendButton.rx.tap
            .bind(to: attendViewModel.tapAttend)
            .disposed(by: disposeBag)
        
        userIdRelay
            .bind(to: attendViewModel.userId)
            .disposed(by: disposeBag)
        
        attendViewModel.attendResult.subscribe(onNext: { [weak self] (response) in
            guard let self = self else { return }
            switch response {
            case .Success(let data):
                debugPrint("data \(data)")
                self.attendResponseData = data
                guard let number = self.attendResponseData?.number else { return }
                self.numberTextField.text = "\(number)"
            case .Error(let error):
                debugPrint("error \(error)")
            }
        }).disposed(by: disposeBag)
        
        attendButton.rx.tap.scan(true) { lastState, newValue in
            return !lastState
            }.subscribe(onNext: { [weak self] (isSelected) in
                guard let self = self else { return }
                self.buttonFlagRelay.accept(isSelected)
                if isSelected {
                    self.attendButton.backgroundColor = UIColor.dddGray
                    self.attendButton.setTitle("출석체크 시작", for: .normal)
                    self.attendButton.setTitleColor(UIColor.white, for: .normal)
                    self.numberTextField.text = ""
                } else {
                    self.attendButton.backgroundColor = UIColor.white
                    self.attendButton.setTitle("출석체크 종료", for: .normal)
                    self.attendButton.setTitleColor(UIColor.dddBlack, for: .normal)
                }
            }).disposed(by: disposeBag)
        
        buttonFlagRelay
            .bind(to: attendViewModel.attendButtonFlag)
            .disposed(by: disposeBag)
    }
    
    private func setupViewStyle(by type: Int) {
        guard let type = UserType.init(rawValue: type) else { fatalError("Invalid User Type") }
        self.view.backgroundColor = type.backgroundColor
        numberTextField.textColor = type.textFieldColor
        numberTextField.isEnabled = type.textFieldEditable
        circleBackgroundImageView.image = type.circleImage
        titleLabel.text = type.titleText
        titleLabel.textColor = type.titleColor
        descriptionLabel.text = type.descriptionText
        descriptionLabel.textColor = type.descriptionColor
        attendButton.setTitle(type.buttonText, for: .normal)
        attendButton.layer.masksToBounds = true
        attendButton.layer.cornerRadius = 6
    }
    
    private func configureShadow(to view: UIView) {
        let shadowView = UIView(
            frame: CGRect(
                x: 0,
                y: 8,
                width: view.bounds.width,
                height: view.bounds.height
            )
        )
        view.insertSubview(shadowView, at: 0)
        self.shadowView = shadowView
        view.applyShadow(
            shadowView: shadowView,
            width: CGFloat(0.0),
            height: CGFloat(0.0)
        )
    }
}
