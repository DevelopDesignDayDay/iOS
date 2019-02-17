//
//  LoginReqeust.swift
//  DDD
//
//  Created by Gunter on 17/02/2019.
//  Copyright © 2019 Gunter. All rights reserved.
//

import Foundation

struct LoginRequest: Codable {
    
    let account: String!

    let password: String!
    
    init(account: String, password: String) {
        self.account = account
        self.password = password
    }
    
}
