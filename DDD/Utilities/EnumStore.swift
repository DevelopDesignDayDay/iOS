//
//  EnumStore.swift
//  DDD
//
//  Created by Gunter on 17/02/2019.
//  Copyright © 2019 Gunter. All rights reserved.
//

import Foundation

public enum Validation {
    case EMPTY_TEXT_FIELD
    case EMPTY_ID
    case EMPTY_PW
    case EMPTY_PW_CONFIRM
    case EMPTY_EMAIL
    case EMPTY_CODE
    case NOT_MATCH_EMAIL
    case NOT_MATCH_PW
}
