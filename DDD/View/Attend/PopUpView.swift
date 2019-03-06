//
//  PopUpView.swift
//  DDD
//
//  Created by ParkSungJoon on 01/03/2019.
//  Copyright © 2019 Gunter. All rights reserved.
//

import UIKit

class PopUpView: UIView {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBAction func acceptButton(_ sender: Any) {
        self.removeAnimate()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        roundCorners(layer: backgroundView.layer, radius: 16)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        roundCorners(layer: backgroundView.layer, radius: 16)
    }
    
    private func commonInit() {
        guard let view = Bundle.main.loadNibNamed(
            "PopUpView",
            owner: self,
            options: nil)?.first as? UIView
            else { return }
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    func setupPopUpView(by userType: Int, _ isSuccess: Bool, _ message: String) {
        switch UserType(userType: userType) {
        case .admin:
            backgroundView.backgroundColor = UIColor.dddRed
        case .general:
            descriptionLabel.text = message
            imageView.image = isSuccess ? #imageLiteral(resourceName: "popupCheckIcon") : #imageLiteral(resourceName: "popupExclamationMarkIcon")
            backgroundView.backgroundColor = UIColor.dddGray
        }
    }
    
    private func removeAnimate() {
        UIView.animate(withDuration: 0.25, animations: {
            self.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.alpha = 0.0
        }) { (finished) in
            if finished {
                self.removeFromSuperview()
            }
        }
    }
}
