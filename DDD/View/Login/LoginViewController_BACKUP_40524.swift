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
    
<<<<<<< HEAD
    private let attendViewControllerIdentifier = "AttendViewController"
=======
    private let splash = SplashAnimationView()
>>>>>>> 0ccfb27d291f3668b310ee528e1ba01c43b76cc1
    
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
            .subscribe(onNext: { [weak self] (response) in
                guard let self = self else { return }
                switch response {
                case .Success(let data):
                    debugPrint("data \(data)")
                    self.setUserDefaults(to: data)
                    self.presentAttendViewController(to: data.user)
                    print(data.user)
                case .Error(let error):
                    debugPrint("error \(error)")
                }
            }).disposed(by: disposeBag)
<<<<<<< HEAD
    }
    
    private func presentAttendViewController(to data: User) {
        guard
            let attendVC = self.storyboard?.instantiateViewController(
                withIdentifier: attendViewControllerIdentifier
            ) as? AttendViewController else { fatalError("Invalid Identifier") }
        attendVC.userType = data.type
        attendVC.userId = data.id
        self.present(attendVC, animated: true, completion: nil)
    }
    
    private func setUserDefaults(to data: LoginResponse) {
        UserDefaults.standard.setValue(data.accessToken, forKey: "accessToken")
        UserDefaults.standard.setValue(data.refreshToken, forKey: "refreshToken")
        UserDefaults.standard.setValue(data.user.id, forKey: "userId")
        UserDefaults.standard.setValue(data.user.type, forKey: "userType")
        UserDefaults.standard.synchronize()
    }
=======
        
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
    
>>>>>>> 0ccfb27d291f3668b310ee528e1ba01c43b76cc1
}
