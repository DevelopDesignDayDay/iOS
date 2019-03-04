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
    
    @IBOutlet weak var loginButton: ButtonWithShadow!
    
    private var loginViewModel: LoginViewModeling!
    
    private let disposeBag = DisposeBag()
    
    private let splash = SplashAnimationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
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
    }
    
    func initView() {
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
            .subscribe(onNext: { (response) in
                switch response {
                case .Success(let data):
                    debugPrint("data \(data)")
                case .Error(let error):
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
                    self.loginButton.backgroundColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
                    self.loginButton.isEnabled = true
                } else {
                    self.loginButton.backgroundColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1.0)
                    self.loginButton.isEnabled = false
                }
                
            }).disposed(by: disposeBag)
        
        
    }
    
}

