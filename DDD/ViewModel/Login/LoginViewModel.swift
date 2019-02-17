//
//  LoginViewModel.swift
//  DDD
//
//  Created by Gunter on 17/02/2019.
//  Copyright © 2019 Gunter. All rights reserved.
//

import RxSwift
import RxCocoa

protocol LoginViewModeling {
    
    // MARK: - Input
    var progressBinding: Observable<Bool> { get }
    
    var account: BehaviorRelay<String> { get }
    
    var password: BehaviorRelay<String> { get }
    
    var tapLogin: PublishSubject<Void> { get }
    
    // MARK: - Output
    var loginResult: Observable<APIResult<LoginResponse>>! { get }
    
}

class LoginViewModel: LoginViewModeling {
    
    // MARK: - Input
    var progressView: ActivityIndicator = ActivityIndicator()
    
    var progressBinding: Observable<Bool> {
        return progressView.asObservable()
    }
    
    var account: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
    
    var password: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
    
    var tapLogin: PublishSubject<Void> = PublishSubject<Void>()
    
    // MARK: - Output
    var loginResult: Observable<APIResult<LoginResponse>>!
    
    init(loginService: LoginServicing) {
        
        let loginRequest =  Observable.combineLatest(account, password)
        
        loginResult = tapLogin.withLatestFrom(loginRequest)
            .filter { (account, password) -> Bool in
                var isValidation = false
                
                if account.count <= 0 {
                    isValidation = false
                } else {
                    isValidation = true
                }
                
                if password.count <= 0 {
                    isValidation = false
                } else {
                    isValidation = true
                }
                
                debugPrint("isValidation \(isValidation)")
                
                return isValidation
            }.flatMapLatest { [unowned self] (account, password) -> Observable<APIResult<LoginResponse>> in
                
                let loginRequest = LoginRequest(account: account, password: password)
                
                let param = loginRequest.dictionary
                
                return loginService.login(param: param)
                    .catchError({ (error) -> Observable<APIResult<LoginResponse>> in
                        Observable.just(APIResult.Error(error))
                    })
                    .trackActivity(self.progressView)
                    .observeOn(MainScheduler.instance)
                
            }
        
        
        
    }
    
    
}

