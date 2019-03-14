//
//  RefreshService.swift
//  DDD
//
//  Created by ParkSungJoon on 07/03/2019.
//  Copyright © 2019 Gunter. All rights reserved.
//

import RxSwift

enum RefreshToken {
    
    case reissue
    
    var url: String {
        switch  self {
        case .reissue:
            return "/auth/token"
        }
    }
}

protocol RefreshServicable {
    
    func reissue(param: [String: Any]?) -> Observable<APIResult<RefreshResponse>>
    
}

class RefreshService: RefreshServicable {
    
    func reissue(param: [String : Any]?) -> Observable<APIResult<RefreshResponse>> {
        let url = RefreshToken.reissue.url
        return Network.shared.requestAuthLogin(method: .post, url: url, parameters: param, type: RefreshResponse.self)
    }
}
