//
//  SignupResponse.swift
//  DDD
//
//  Created by Gunter on 09/03/2019.
//  Copyright © 2019 Gunter. All rights reserved.
//

import Himotoki

struct SignupResponse {
    
    let status: String
    
    let userId: Int
    
}

extension SignupResponse: Himotoki.Decodable {
    
    static func decode(_ e: Extractor) throws -> SignupResponse {
        return try SignupResponse(
            status: e <| "status",
            userId: e <| "userId"
        )
    }
    
}


