//
//  LoginResponse.swift
//  DDD
//
//  Created by Gunter on 17/02/2019.
//  Copyright © 2019 Gunter. All rights reserved.
//

import Himotoki

struct LoginResponse {
    
    let status: String
    
    let user: User
    
    let accessToken: String
    
    let refreshToken: String

}

extension LoginResponse: Himotoki.Decodable {
    
    static func decode(_ e: Extractor) throws -> LoginResponse {
        return try LoginResponse(
            status: e <| "status",
            user: e <| "user",
            accessToken: e <| "accessToken",
            refreshToken: e <| "refreshToken"
        )
    }
    
}


struct User {
    
    let id: Int
    
    let name: String
    
    let account: String
    
    let type: Int

}

extension User: Himotoki.Decodable {
    
    static func decode(_ e: Extractor) throws -> User {
        return try User(
            id: e <| "id",
            name: e <| "name",
            account: e <| "account",
            type: e <| "type"
        )
    }
    
}
