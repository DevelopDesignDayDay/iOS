//
//  ApiError.swift
//  DDD
//
//  Created by Gunter on 17/02/2019.
//  Copyright © 2019 Gunter. All rights reserved.
//

import Foundation

protocol ApiErrorProtocol: LocalizedError {
    
    var date: String? { get }
    
    var errorCode: String? { get }
    
    var status: Int? { get }
    
    var message: String? { get }
    
    var path: String? { get }
    
}

struct ApiError: Error {
    
    var date: String?
    
    var errorCode: String?
    
    var status: Int?
    
    var message: String?
    
    var path: String?
    
    init(date: String?, errorCode: String?, status: Int?, message: String?, path: String?) {
        self.date = date
        self.errorCode = errorCode
        self.status = status
        self.message = message
        self.path = path
    }
    
}
