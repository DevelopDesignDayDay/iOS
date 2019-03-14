//
//  SignupRequest.swift
//  DDD
//
//  Created by Gunter on 09/03/2019.
//  Copyright © 2019 Gunter. All rights reserved.
//

import Foundation

struct SignupRequest: Codable {
    
    let account: String
    
    let password: String
    
    let name: String
    
    let email: String
    
    let code: String
    
    let type: Int
    
    init(account: String, password: String, name: String, email: String, code: String, type: Int) {
        self.account = account
        self.password = password
        self.name = name
        self.email = email
        self.code = code
        self.type = type
    }
    
}
