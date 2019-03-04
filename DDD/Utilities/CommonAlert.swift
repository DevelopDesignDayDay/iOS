//
//  CommonAlert.swift
//  DDD
//
//  Created by Gunter on 04/03/2019.
//  Copyright © 2019 Gunter. All rights reserved.
//

import UIKit

public class CommonAlert {
    
    class func ShowAlert(title: String, message: String, in vc: UIViewController) {
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "confirm".localized,
                                      style: UIAlertAction.Style.default,
                                      handler: nil))
        
        vc.present(alert,
                   animated: true,
                   completion: nil)
        
    }
    
    class func ShowApiErrorAlert(error: Error, in vc: UIViewController) {
        
        guard let apiError = error as? ApiError else {
            return
        }
        
        let alert = UIAlertController(title: "info".localized,
                                      message: apiError.message,
                                      preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "confirm".localized,
                                      style: UIAlertAction.Style.default,
                                      handler: nil))
        
        vc.present(alert,
                   animated: true,
                   completion: nil)
        
    }
    
    class func ShowValidationErrorAlert(error: Error, in vc: UIViewController) {
        
        guard let validationError = error as? ValidationError else {
            return
        }
        
        let alert = UIAlertController(title: "info".localized,
                                      message: validationError.message,
                                      preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "confirm".localized,
                                      style: UIAlertAction.Style.default,
                                      handler: nil))
        
        vc.present(alert,
                   animated: true,
                   completion: nil)
        
    }
    
}
