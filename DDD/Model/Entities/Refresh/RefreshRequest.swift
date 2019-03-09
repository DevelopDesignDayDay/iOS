//
//  RefreshRequest.swift
//  DDD
//
//  Created by ParkSungJoon on 07/03/2019.
//  Copyright © 2019 Gunter. All rights reserved.
//

import Foundation

struct RefreshRequest: Codable {
    
    let refreshToken: String
    
    init(refreshToken: String) {
        self.refreshToken = refreshToken
    }
}
