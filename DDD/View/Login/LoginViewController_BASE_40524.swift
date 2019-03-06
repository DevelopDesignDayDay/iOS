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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginViewModel = LoginViewModel(loginService: LoginService())
        setupRx()
    }
    
    func initView() {
        
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
        
    }

}

