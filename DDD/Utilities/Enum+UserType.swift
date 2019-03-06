//
//  Enum+UserType.swift
//  DDD
//
//  Created by ParkSungJoon on 02/03/2019.
//  Copyright © 2019 Gunter. All rights reserved.
//

import Foundation
import UIKit

enum UserType: Int {
    case general = 2
    case admin = 1
    
    init(userType: Int) {
        switch userType {
        case 1: self = .admin
        default: self = .general
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .general: return UIColor.white
        case .admin: return UIColor.black
        }
    }
    
    var circleImage: UIImage {
        switch self {
        case .general: return #imageLiteral(resourceName: "normalBlackRound")
        case .admin: return #imageLiteral(resourceName: "adminWhiteRound")
        }
    }
    
    var titleColor: UIColor {
        switch self {
        case .general: return UIColor.dddGray
        case .admin: return UIColor.white
        }
    }
    
    var descriptionColor: UIColor {
        switch self {
        case .general: return UIColor.dddLightGray
        case .admin: return UIColor.white
        }
    }
    
    var textFieldColor: UIColor {
        switch self {
        case .general: return UIColor.white
        case .admin: return UIColor.dddBlack
        }
    }
    
    var textFieldEditable: Bool {
        switch self {
        case .general: return true
        case .admin: return false
        }
    }
    
    var titleText: String {
        switch self {
        case .general: return "번호 입력해주세요"
        case .admin: return "출석체크를 시작해주세요"
        }
    }
    
    var descriptionText: String {
        switch self {
        case .general: return "라운드에 번호를 입력해주셔야 출석 체크 버튼이\n 활성화가 되어 출석 체크가 가능합니다."
        case .admin: return "라운드에 나오는 숫자를 멤버들에게 알려주셔야\n 멤버분들이 출석 체크가 가능합니다."
        }
    }
    
    var buttonText: String {
        switch self {
        case .general: return "출석체크"
        case .admin: return "출석체크 시작"
        }
    }
}
