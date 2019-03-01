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
    func start() -> Observable<APIResult<AttendResponse>>
    func end() -> Observable<APIResult<AttendResponse>>
    func check(param: [String: Any]?) -> Observable<APIResult<AttendResponse>>
}

class AttendService: AttendServicable {
    func start() -> Observable<APIResult<AttendResponse>> {
        let url = Attend.start.url
        return Network.shared.request(method: .post, url: url, parameters: nil, type: AttendResponse.self)
    }
    
    func end() -> Observable<APIResult<AttendResponse>> {
        let url = Attend.end.url
        return Network.shared.request(method: .post, url: url, parameters: nil, type: AttendResponse.self)
    }
    
    func check(param: [String : Any]?) -> Observable<APIResult<AttendResponse>> {
        let url = Attend.check.url
        return Network.shared.request(method: .post, url: url, parameters: param, type: AttendResponse.self)
    }
}
