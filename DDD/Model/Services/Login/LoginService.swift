//
//  LoginService.swift
//  DDD
//
//  Created by Gunter on 17/02/2019.
//  Copyright © 2019 Gunter. All rights reserved.
//

import RxSwift

enum Login {
    
    case login()

    var url: String {
        switch  self {
        case .login:
            return "/auth/login"
        }
    }
    
}

protocol LoginServicing {
    
    func login(param: [String: Any]?) -> Observable<APIResult<LoginResponse>>
    
}

class LoginService: LoginServicing {
    
    func login(param: [String : Any]?) -> Observable<APIResult<LoginResponse>> {
        let url = Login.login().url
        return Network.shared.requestAuthLogin(method: .post, url: url, parameters: param, type: LoginResponse.self)
    }
    
}
