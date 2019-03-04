//
//  Extension+UIView.swift
//  DDD
//
//  Created by ParkSungJoon on 03/03/2019.
//  Copyright © 2019 Gunter. All rights reserved.
//

import UIKit

extension UIView {
    func applyShadow(shadowView: UIView, width: CGFloat, height: CGFloat) {
        let shadowPath = UIBezierPath(roundedRect: shadowView.bounds, cornerRadius: 6)
        shadowView.layer.masksToBounds = false
        shadowView.layer.shadowRadius = 6
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOffset = CGSize(width: width, height: height)
        shadowView.layer.shadowOpacity = 0.24
        shadowView.layer.shadowPath = shadowPath.cgPath
    }
    
    func roundCorners(layer targetLayer: CALayer, radius withRaidus: CGFloat) {
        targetLayer.cornerRadius = withRaidus
        targetLayer.masksToBounds = true
    }
}
