//
//  SignupViewModel.swift
//  DDD
//
//  Created by Gunter on 09/03/2019.
//  Copyright © 2019 Gunter. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol SignupViewModeling {

    // MARK: - Input
    var progressBinding: Observable<Bool> { get }
    
    var account: BehaviorRelay<String> { get }
    
    var name: BehaviorRelay<String> { get }
    
    var password: BehaviorRelay<String> { get }
    
    var passwordConfirm: BehaviorRelay<String> { get }
    
    var email: BehaviorRelay<String> { get }
    
    var signupCode: BehaviorRelay<String> { get }

    var tapSignup: PublishSubject<Void> { get }
    
    // MARK: - Output
    var signUpResult: Observable<APIResult<SignupResponse>>! { get }
        
}

class SignupViewModel: SignupViewModeling {
    
    // MARK: - Input
    var progressView: ActivityIndicator = ActivityIndicator()
    
    var progressBinding: Observable<Bool> {
        return progressView.asObservable()
    }
    
    var account: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
    
    var name: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
    
    var password: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
    
    var passwordConfirm: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
    
    var email: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
    
    var signupCode: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
    
    var tapSignup: PublishSubject<Void> = PublishSubject<Void>()
    
    // MARK: - Output
    var signUpResult: Observable<APIResult<SignupResponse>>!
    
    init(signupService: SignupServicing) {
        
        let signupRequest = Observable.combineLatest(account, name, password, passwordConfirm, email, signupCode)
        
        signUpResult = tapSignup.withLatestFrom(signupRequest)
            .filter({ (account, name, password, passwordConfirm, email, signupCode) -> Bool in
                
                if account.count <= 0 {
                    return false
                }
                
                if name.count <= 0 {
                    return false
                }
                
                if password.count <= 0 {
                    return false
                }
                
                if passwordConfirm.count <= 0 {
                    return false
                }
                
                if password != passwordConfirm {
                    return false
                }
                
                if email.count <= 0 {
                    return false
                }
                
                if signupCode.count <= 0 {
                    return false
                }
 
                return true
                
            }).flatMapLatest({ [unowned self] (account, name, password, passwordConfirm, email, signupCode) -> Observable<APIResult<SignupResponse>> in
                let signUp = SignupRequest(account: account, password: password, name: name, email: email, code: signupCode, type: 2)
                let param = signUp.dictionary
                
                debugPrint("param \(param)")
                
                return signupService.signup(param: param)
                    .catchError({ (error) -> Observable<APIResult<SignupResponse>> in
                        return Observable.just(APIResult.Error(error))
                    }).trackActivity(self.progressView)
            }).observeOn(MainScheduler.instance)
        
    }
    
    deinit {
        debugPrint("signup vm deinit")
    }
    
}
