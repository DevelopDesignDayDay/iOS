//
//  AttendService.swift
//  DDD
//
//  Created by ParkSungJoon on 28/02/2019.
//  Copyright © 2019 Gunter. All rights reserved.
//

import RxSwift

enum Attend {
    case start
    case end
    case check
    
    var url: String {
        switch  self {
        case .start: return "/attends/start"
        case .end: return "/attends/end"
        case .check: return "/attends/check"
        }
    }
}

protocol AttendServicable {
    func start(token: String) -> Observable<APIResult<AttendResponse>>
    func end(token: String) -> Observable<APIResult<AttendResponse>>
    func check(token: String, param: [String: Any]?) -> Observable<APIResult<AttendResponse>>
}

class AttendService: AttendServicable {
    func start(token: String) -> Observable<APIResult<AttendResponse>> {
        let url = Attend.start.url
        return Network.shared.requestWith(method: .post, url: url, parameters: nil, authToken: token, type: AttendResponse.self)
    }
    
    func end(token: String) -> Observable<APIResult<AttendResponse>> {
        let url = Attend.end.url
        return Network.shared.requestWith(method: .post, url: url, parameters: nil, authToken: token, type: AttendResponse.self)
    }
    
    func check(token: String, param: [String : Any]?) -> Observable<APIResult<AttendResponse>> {
        let url = Attend.check.url
        return Network.shared.requestWith(method: .post, url: url, parameters: param, authToken: token, type: AttendResponse.self)
    }
}
