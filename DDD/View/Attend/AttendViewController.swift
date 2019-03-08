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
    
    @IBOutlet weak var refreshPopUpBackgroundView: UIView!
    @IBOutlet weak var refreshPopupView: UIView! {
        didSet {
            refreshPopupView.layer.masksToBounds = true
            refreshPopupView.layer.cornerRadius = 16
        }
    }
    @IBOutlet weak var refreshPopupButton: UIButton!
    @IBAction func refreshPopupButton(_ sender: Any) {
        refreshPopUpBackgroundView.isHidden = true
    }
    
    private var attendViewModel = AttendViewModel(attendService: AttendService(), refreshService: RefreshService())
    private weak var shadowView: UIView?
    private let disposeBag = DisposeBag()
    private let splash = SplashAnimationView()
    private var refreshAction: UIAlertAction!
    private let loginViewControllerIdentifier = "LoginViewController"
    
    var userType: Int? {
        didSet {
            guard let userType = userType else { return }
            setupViewUI(by: userType)
        }
    }
    var userId: Int? {
        didSet {
            guard let userId = self.userId else { return }
            self.userIdRelay.accept(userId)
        }
    }
    var isSplash: Bool? {
        didSet {
            view.addSubview(splash)
            splash.pinEdgesToSuperView()
        }
    }
    var refreshToken: String? {
        didSet {
            guard let refreshToken = refreshToken else { return }
            self.refreshTokenRelay.accept(refreshToken)
        }
    }
    var accessToken: String? {
        didSet {
            guard let accessToken = accessToken else { return }
            self.accessTokenRelay.accept(accessToken)
        }
    }
    
    var userIdRelay: BehaviorRelay<Int> = BehaviorRelay(value: -1)
    var buttonFlagRelay: BehaviorRelay<Bool> = BehaviorRelay(value: true)
    var refreshTokenRelay: BehaviorRelay<String> = BehaviorRelay(value: "")
    var accessTokenRelay: BehaviorRelay<String> = BehaviorRelay(value: "")
    var attendResponseData: AttendResponse?
    let refreshService = RefreshService()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        guard let userType = userType else { fatalError() }
        switch UserType(userType: userType) {
        case .general: return .default
        case .admin: return .lightContent
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshToken = UserDefaults.standard.string(forKey: "refreshToken")
        accessToken = UserDefaults.standard.string(forKey: "accessToken")
        numberTextField.delegate = self
        setupRx()
        configureShadow(to: buttonBackgroundView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        splash.splash.play { [unowned self] (isComplete) in
            self.splash.isHidden = true
            debugPrint("isPlay \(isComplete)")
        }
        
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
        
        buttonFlagRelay
            .bind(to: attendViewModel.attendButtonFlag)
            .disposed(by: disposeBag)
        
        refreshTokenRelay
            .bind(to: attendViewModel.refreshToken)
            .disposed(by: disposeBag)
        
        accessTokenRelay
            .bind(to: attendViewModel.accessToken)
            .disposed(by: disposeBag)
        
        refreshPopupButton.rx.tap
            .bind(to: attendViewModel.tapRefresh)
            .disposed(by: disposeBag)
        
        attendViewModel.attendResult.subscribe(onNext: { [weak self] (response) in
            guard let self = self else { return }
            guard let userType = self.userType else { return }
            switch response {
            case .Success(let data):
                self.attendResponseData = data
                switch UserType(userType: userType) {
                case .admin:
                    guard let number = self.attendResponseData?.number else { return }
                    self.numberTextField.text = "\(number)"
                case .general:
                    guard let message = data.message else { return }
                    let popUpView = PopUpView(frame: self.view.bounds)
                    popUpView.setupPopUpView(by: userType, true, message)
                    self.showAnimation(to: popUpView)
                }
            case .Error(let error):
                debugPrint(error)
                guard let apiError = error as? ApiError else { return }
                guard let message = apiError.message else { return }
                if message == "Invalid Token" {
                    self.refreshPopUpBackgroundView.isHidden = false
                } else {
                    switch UserType(userType: userType) {
                    case .admin:
                        return
                    case .general:
                        let popUpView = PopUpView(frame: self.view.bounds)
                        popUpView.setupPopUpView(by: userType, false, message)
                        self.showAnimation(to: popUpView)
                    }
                }
            }
        }).disposed(by: disposeBag)
        
        if let formValidation = attendViewModel.formValidation {
            formValidation.subscribe(onNext: { [weak self] (textField) in
                guard let self = self else { return }
                if textField.count > 0 {
                    self.attendButton.backgroundColor = UIColor.dddBlack
                } else {
                    self.attendButton.backgroundColor = UIColor.dddButtonGray
                }
            }).disposed(by: disposeBag)
        }
        
        attendButton.rx.tap.scan(true) { lastState, newValue in
            return !lastState
            }.subscribe(onNext: { [weak self] (isSelected) in
                guard let self = self else { return }
                guard let userType = self.userType else { return }
                self.buttonFlagRelay.accept(isSelected)
                switch UserType(userType: userType) {
                case .admin:
                    self.setupAttendButton(by: isSelected)
                case .general:
                    return
                }
        }).disposed(by: disposeBag)
        
        attendViewModel.refreshResult.subscribe(onNext: { [weak self] (response) in
            guard let self = self else { return }
            switch response {
            case .Success(let data):
                debugPrint(data)
                UserDefaults.standard.setValue(data.accessToken, forKey: "accessToken")
                UserDefaults.standard.setValue(data.refreshToken, forKey: "refreshToken")
                UserDefaults.standard.synchronize()
                self.accessToken = data.accessToken
                self.refreshToken = data.refreshToken
                let popUpView = PopUpView(frame: self.view.bounds)
                popUpView.setupPopUpView(by: 1, true, "토큰이\n갱신되었습니다.")
                self.showAnimation(to: popUpView)
            case .Error(let error):
                debugPrint(error)
                let domain = Bundle.main.bundleIdentifier!
                UserDefaults.standard.removePersistentDomain(forName: domain)
                UserDefaults.standard.synchronize()
                let loginVC = self.storyboard?.instantiateViewController(withIdentifier: self.loginViewControllerIdentifier)
                UIApplication.shared.keyWindow?.rootViewController = loginVC
            }
        }).disposed(by: disposeBag)
    }
    
    private func setupAttendButton(by isSelected: Bool) {
        let title = isSelected ? "출석체크 시작" : "출석체크 종료"
        let color = isSelected ? UIColor.white : UIColor.dddBlack
        attendButton.backgroundColor = isSelected ? UIColor.dddButtonGray : UIColor.white
        attendButton.setTitle(title, for: .normal)
        attendButton.setTitleColor(color, for: .normal)
        if isSelected {
            numberTextField.text = ""
        }
    }
    
    private func setupViewUI(by type: Int) {
        guard let type = UserType.init(rawValue: type) else {
            fatalError("Invalid User Type")
        }
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
    
    private func showAnimation(to view : UIView) {
        UIView.transition(
            with: self.view,
            duration: 0.25,
            options: [.transitionCrossDissolve],
            animations: {
                self.view.addSubview(view)
        }, completion: nil)
    }
}

extension AttendViewController: UITextFieldDelegate {
    
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard let text = textField.text else { return true }
        let count = text.count + string.count - range.length
        return count <= 2
    }
}
