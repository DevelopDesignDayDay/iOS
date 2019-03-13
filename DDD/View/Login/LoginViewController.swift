//
//  LoginViewController.swift
//  DDD
//
//  Created by Gunter on 17/02/2019.
//  Copyright © 2019 Gunter. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SVProgressHUD

class LoginViewController: UIViewController {
    
    @IBOutlet weak var idTextField: UnderLineTextField!
    
    @IBOutlet weak var passwordTextField: UnderLineTextField!
    
    @IBOutlet weak var loginButtonBgView: UIView!
    
    @IBOutlet weak var loginButton: UIButton!
        
    private var loginViewModel: LoginViewModeling!
    
    private let disposeBag = DisposeBag()
    
    private let attendViewControllerIdentifier = "AttendViewController"

    private let splash = SplashAnimationView()
    
    private weak var shadowView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginViewModel = LoginViewModel(loginService: LoginService())
        setupRx()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //splash.splash.animationSpeed
        
        splash.splash.play { [unowned self] (isComplete) in
            self.splash.isHidden = true
            debugPrint("isPlay \(isComplete)")
        }
        
        initView()
        
    }
    
    func initView() {
        
        loginButton.layer.masksToBounds = true
        loginButton.layer.cornerRadius = 6
        configureShadow(to: loginButtonBgView)
        
        view.addSubview(splash)
        splash.pinEdgesToSuperView()
        
    }
    
    func setupRx() {
        
        loginViewModel.progressBinding
            .bind(to: SVProgressHUD.rx.isAnimating)
            .disposed(by: disposeBag)
    
        idTextField.rx.text.orEmpty
            .bind(to: loginViewModel.account)
            .disposed(by: disposeBag)
        
        passwordTextField.rx.text.orEmpty
            .bind(to: loginViewModel.password)
            .disposed(by: disposeBag)
        
        loginButton.rx.tap
            .bind(to: loginViewModel.tapLogin)
            .disposed(by: disposeBag)
        
        loginViewModel.loginResult
            .subscribe(onNext: { [unowned self] (response) in
                switch response {
                case .Success(let data):
                    debugPrint("data \(data)")
                    self.setUserDefaults(to: data)
                    self.presentAttendViewController(to: data.user)
                    print(data.user)
                case .Error(let error):
                    CommonAlert.ShowApiErrorAlert(error: error, in: self)
                    debugPrint("error \(error)")
                }
            }).disposed(by: disposeBag)
        
        loginViewModel.emptyError
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (error) in
                CommonAlert.ShowValidationErrorAlert(error: error, in: self)
            }).disposed(by: disposeBag)
        
        loginViewModel.formValidation
            .subscribe(onNext: { [unowned self] (account, pw) in
                debugPrint("account \(account) pw \(pw)")
                
                if account.count > 0 && pw.count > 0 {
                    self.loginButton.backgroundColor = UIColor.dddBlack
                    //self.loginButton.isEnabled = true
                } else {
                    self.loginButton.backgroundColor = UIColor.dddButtonGray  
                    //self.loginButton.isEnabled = false
                }
                
            }).disposed(by: disposeBag)
        
        
    }
    
    private func presentAttendViewController(to data: User) {
        guard
            let attendVC = self.storyboard?.instantiateViewController(
                withIdentifier: attendViewControllerIdentifier
                ) as? AttendViewController else { fatalError("Invalid Identifier") }
        attendVC.userType = data.type
        attendVC.userId = data.id
        self.present(attendVC, animated: false, completion: nil)
    }
    
    private func setUserDefaults(to data: LoginResponse) {
        UserDefaults.standard.setValue(data.accessToken, forKey: "accessToken")
        UserDefaults.standard.setValue(data.refreshToken, forKey: "refreshToken")
        UserDefaults.standard.setValue(data.user.id, forKey: "userId")
        UserDefaults.standard.setValue(data.user.type, forKey: "userType")
        UserDefaults.standard.synchronize()
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
