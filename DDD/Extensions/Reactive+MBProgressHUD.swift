//
//  Reactive+MBProgressHUD.swift
//  DDD
//
//  Created by Gunter on 17/02/2019.
//  Copyright © 2019 Gunter. All rights reserved.
//

import Foundation
import SVProgressHUD
import RxSwift
import RxCocoa

extension Reactive where Base: SVProgressHUD {
    
    public static var isAnimating: Binder<Bool> {
        return Binder(UIApplication.shared) {_, isVisible in
            if isVisible {
                SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
                SVProgressHUD.setBackgroundLayerColor(UIColor.black)
                SVProgressHUD.show()
            } else {
                SVProgressHUD.dismiss()
            }
        }
    }
    
}
