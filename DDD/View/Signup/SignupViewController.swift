//
//  SignupViewController.swift
//  DDD
//
//  Created by Gunter on 09/03/2019.
//  Copyright © 2019 Gunter. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SVProgressHUD

class SignupViewController: UIViewController {

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var idTextField: UnderLineTextField!
    
    @IBOutlet weak var nameTextField: UnderLineTextField!
    
    @IBOutlet weak var passwordTextField: UnderLineTextField!
    
    @IBOutlet weak var passwordConfirmTextField: UnderLineTextField!
    
    @IBOutlet weak var emailTextField: UnderLineTextField!
    
    @IBOutlet weak var signupCodeTextField: UnderLineTextField!
    
    @IBOutlet weak var tapSignupBg: UIView!
    
    @IBOutlet weak var signupButton: UIButton!

    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    private var signupViewModel: SignupViewModeling!
    
    private weak var shadowView: UIView?
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signupViewModel = SignupViewModel(signupService: SignupService())
        setupRx()
        navigationBar.setValue(true, forKey: "hidesShadow")
        setupSignUpButtonShadowView()
    }
    
    private func setupSignUpButtonShadowView() {
        signupButton.layer.masksToBounds  = true
        signupButton.layer.cornerRadius = 6
        configureShadow(to: tapSignupBg)
    }
    
    func setupRx() {
        
        signupViewModel.progressBinding
            .bind(to: SVProgressHUD.rx.isAnimating)
            .disposed(by: disposeBag)
        
        let id = idTextField.rx.text.orEmpty.share(replay: 1)
        
        let name = nameTextField.rx.text.orEmpty.share(replay: 1)
        
        let password = passwordTextField.rx.text.orEmpty.share(replay: 1)
        
        let passwordConfirm = passwordConfirmTextField.rx.text.orEmpty.share(replay: 1)
        
        let email = emailTextField.rx.text.orEmpty.share(replay: 1)
        
        let signupCode = signupCodeTextField.rx.text.orEmpty.share(replay: 1)
        
        let tapSignup = signupButton.rx.tap.share(replay: 1)

        let idValidator = TextValidator(input: id)
        
        let nameValidator = TextValidator(input: name)
        
        let passwordValidator = TextValidator(input: password)
        
        let passwordConfirmValidator = TextValidator(input: passwordConfirm)
        
        let emailValidator = TextValidator(input: email)
        
        let signupCodeValidator = TextValidator(input: signupCode)
        
        let equalPassword = Observable.combineLatest(password, passwordConfirm)
            .map { (pw, pwConfirm) -> Bool in
                debugPrint("\(pw) \(pwConfirm) \(pw != pwConfirm)")
                return pw == pwConfirm
            }
        
        let formValidate = Observable.combineLatest(idValidator.validate(),
                                                    nameValidator.validate(),
                                                    passwordValidator.validate(),
                                                    passwordConfirmValidator.validate(),
                                                    emailValidator.validate(),
                                                    emailValidator.isEamilvalidate(),
                                                    signupCodeValidator.validate(),
                                                    equalPassword).share(replay: 1)
        
    
        formValidate.subscribe(onNext: { [unowned self] (id, name, password , passwordConfirm,
            email, emailRegular, signupCode, _) in
            
            if id && name && password && passwordConfirm && email && emailRegular && signupCode {
                self.signupButton.backgroundColor = UIColor.dddBlack
            } else {
                self.signupButton.backgroundColor = UIColor.dddButtonGray
            }
           
            debugPrint("id \(id) name \(name) password \(password) passwrodConfirm \(passwordConfirm) email \(email) emailRegular \(emailRegular) signupcode \(signupCode)")
            
        }).disposed(by: disposeBag)
        
        tapSignup.withLatestFrom(formValidate)
            .subscribe(onNext: { [unowned self] (id, name, password , passwordConfirm,
                email, emailRegular, signupCode, equalPw) in
                
                var validationError: ValidationError?
                
                if !id {
                    validationError = ValidationError(
                        errorCode: .EMPTY_ID,
                        message: "empty_id_info".localized
                    )
                    
                } else if !name {
                    
                    validationError = ValidationError(
                        errorCode: .EMPTY_PW,
                        message: "empty_name_info".localized
                    )
                    
                } else if !password {
                    
                    validationError = ValidationError(
                        errorCode: .EMPTY_PW,
                        message: "empty_pw_info".localized
                    )
                    
                } else if !passwordConfirm {
                    
                    validationError = ValidationError(
                        errorCode: .EMPTY_PW_CONFIRM,
                        message: "empty_pw_confirm".localized
                    )
                    
                } else if !email {
                    
                    validationError = ValidationError(
                        errorCode: .EMPTY_EMAIL,
                        message: "empty_email".localized
                    )
                    
                } else if !emailRegular {
                    
                    validationError = ValidationError(
                        errorCode: .NOT_MATCH_EMAIL,
                        message: "not_match_email".localized
                    )
                    
                } else if !signupCode {
                    
                    validationError = ValidationError(
                        errorCode: .EMPTY_CODE,
                        message: "empty_code".localized
                    )
                    
                } else if !equalPw {
                    
                    validationError = ValidationError(
                        errorCode: .NOT_MATCH_PW,
                        message: "not_match_pw".localized
                    )
                    
                }
                
                if let error = validationError {
                    CommonAlert.ShowValidationErrorAlert(error: error, in: self)
                }
                
            }).disposed(by: disposeBag)
        
        id.bind(to: signupViewModel.account)
            .disposed(by: disposeBag)
        
        name.bind(to: signupViewModel.name)
            .disposed(by: disposeBag)
        
        password.bind(to: signupViewModel.password)
            .disposed(by: disposeBag)
        
        passwordConfirm.bind(to: signupViewModel.passwordConfirm)
            .disposed(by: disposeBag)
        
        email.bind(to: signupViewModel.email)
            .disposed(by: disposeBag)
        
        signupCode.bind(to: signupViewModel.signupCode)
            .disposed(by: disposeBag)
        
        tapSignup.bind(to: signupViewModel.tapSignup)
            .disposed(by: disposeBag)
        
        cancelButton.rx.tap
            .subscribe(onNext: { [unowned self] _ in
                self.navigationController?.popViewController(animated: true)
            }).disposed(by: disposeBag)
    
        signupViewModel.signUpResult
            .subscribe(onNext: { [unowned self] (result) in
                switch result {
                case .Success(_):
                    self.showAlert(message: "signup_complete".localized)
                case .Error(let error):
                    debugPrint("error \(error)")
                    CommonAlert.ShowApiErrorAlert(error: error, in: self)
                }
            }).disposed(by: disposeBag)
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
    
    private func showAlert(message: String) {
        
        let alertController = UIAlertController(title: "info".localized,
                                                message: message,
                                                preferredStyle: UIAlertController.Style.alert)
        
        alertController.addAction(
            UIAlertAction(
                title: "확인",
                style: UIAlertAction.Style.default,
                handler: { action in
                    self.navigationController?.popViewController(animated: true)
            })
        )
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    deinit {
        debugPrint("signup vc deinit")
    }
    
}
