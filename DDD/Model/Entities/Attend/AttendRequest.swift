//
//  AttendRequest.swift
//  DDD
//
//  Created by ParkSungJoon on 01/03/2019.
//  Copyright © 2019 Gunter. All rights reserved.
//

import Foundation

struct AttendRequest: Codable {
    let userId: String
    let number: String
    
    init(userId: String, number: String) {
        self.userId = userId
        self.number = number
    }
}
