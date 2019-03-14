//
//  RefreshResponse.swift
//  DDD
//
//  Created by ParkSungJoon on 07/03/2019.
//  Copyright © 2019 Gunter. All rights reserved.
//

import Himotoki

struct RefreshResponse {
    
    let status: String
    let accessToken: String
    let refreshToken: String
}

extension RefreshResponse: Himotoki.Decodable {
    
    static func decode(_ e: Extractor) throws -> RefreshResponse {
        return try RefreshResponse(
            status: e <| "status",
            accessToken: e <| "accessToken",
            refreshToken: e <| "refreshToken"
        )
    }
    
}
