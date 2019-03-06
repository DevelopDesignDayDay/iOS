//
//  DeviceFontSizeLabel+iPhone5.swift
//  DDD
//
//  Created by Gunter on 05/03/2019.
//  Copyright © 2019 Gunter. All rights reserved.
//

import UIKit


extension UILabel {
    @IBInspectable var font_5s: CGFloat {
        get { fatalError("Only available in Interface Builder.") }
        set { updateFontSize(target: .iPhone_5, fontSize: newValue) }
    }
}
