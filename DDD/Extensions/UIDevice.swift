//
//  UIDevice.swift
//  DDD
//
//  Created by Gunter on 05/03/2019.
//  Copyright © 2019 Gunter. All rights reserved.
//

import UIKit

extension UIDevice {
    
    static var isiPadMini: Bool {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPad2,5", "iPad2,6", "iPad2,7",
             "iPad4,4", "iPad4,5", "iPad4,6",
             "iPad4,7", "iPad4,8", "iPad4,9",
             "iPad5,1", "iPad5,2":
            return true
        default: return false
        }
    }
    
}

extension UILabel {
    enum DeviceType {
        case iPhone_4, iPhone_5, iPhone_6, iPhone_6plus
        case iPad, iPad_Mini, iPad_Pro
    }
    
    func isTargetDevice(target: DeviceType) -> Bool {
        let screenHeight = UIScreen.main.bounds.height
        switch screenHeight {
        case 480: return .iPhone_4 == target
        case 568: return .iPhone_5 == target
        case 667: return .iPhone_6 == target
        case 736: return .iPhone_6plus == target
        case 1024: return UIDevice.isiPadMini ? .iPad_Mini == target : .iPad == target
        case 1366: return .iPad_Pro == target
        default: return false
        }
    }
    
    func updateFontSize(target: DeviceType, fontSize: CGFloat) {
        guard isTargetDevice(target: target) && 0 < fontSize else {
            return
        }
        self.font = self.font.withSize(fontSize)
    }
}
