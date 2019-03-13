//
//  SignupService.swift
//  DDD
//
//  Created by Gunter on 09/03/2019.
//  Copyright © 2019 Gunter. All rights reserved.
//

import RxSwift

enum SignUp {
    case signup
    
    var url: String {
        switch self {
        case .signup:
            return "/users"
        }
    }
    
}

protocol SignupServicing {
    
    func signup(param: [String: Any]?) -> Observable<APIResult<SignupResponse>>
    
}

class SignupService: SignupServicing {
    
    func signup(param: [String : Any]?) -> Observable<APIResult<SignupResponse>> {
        let url = SignUp.signup.url
        return Network.shared.request(method: .post, url: url, parameters: param, type: SignupResponse.self)
    }
    
    deinit {
        debugPrint("signup service deinit")
    }
    
}
