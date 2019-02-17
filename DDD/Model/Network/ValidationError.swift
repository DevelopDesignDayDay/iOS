//
//  ValidationError.swift
//  DDD
//
//  Created by Gunter on 17/02/2019.
//  Copyright © 2019 Gunter. All rights reserved.
//

import Foundation

enum ValidationResult<T> {
    case Success(T)
    case Error(Error)
}

struct ValidationError: Error {
    
    var errorCode: Validation
    
    var message: String
    
    init(errorCode: Validation, message: String) {
        self.errorCode = errorCode
        self.message = message
    }
    
}
