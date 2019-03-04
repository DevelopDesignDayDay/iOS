//
//  SplashAnimationView.swift
//  DDD
//
//  Created by Gunter on 04/03/2019.
//  Copyright © 2019 Gunter. All rights reserved.
//

import UIKit
import Lottie

class SplashAnimationView: UIView {
    
    let splash = LOTAnimationView(name: "ddd_splash")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        splashInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        splashInit()
    }
    
    private func splashInit() {
        debugPrint("ddd")
        backgroundColor = UIColor.black
        // Set view to full screen, aspectFill
        splash.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        splash.contentMode = .scaleAspectFill
        // Add the Animation
        addSubview(splash)
        splash.translatesAutoresizingMaskIntoConstraints = false
        splash.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        splash.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
}
