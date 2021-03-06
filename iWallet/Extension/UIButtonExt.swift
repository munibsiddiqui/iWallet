//
//  UIButtonExt.swift
//  goalpost-app
//
//  Created by Sergey Guznin on 3/23/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit

extension UIButton {
    func setSelectedColor(){
        self.backgroundColor = #colorLiteral(red: 0, green: 0.5690457821, blue: 0.5746168494, alpha: 1)
    }
    
    func setDeselectedColor(){
        self.backgroundColor = #colorLiteral(red: 0.001855805167, green: 0.569607079, blue: 0.5755836368, alpha: 0.5)
    }
    
//    func centerImageAndButton(_ gap: CGFloat, imageOnTop: Bool) {
//        
//        guard let imageView = self.imageView,
//            let titleLabel = self.titleLabel else { return }
//        
//        let sign: CGFloat = imageOnTop ? 1 : -1;
//        let imageSize = imageView.frame.size;
//        self.titleEdgeInsets = UIEdgeInsetsMake((imageSize.height+gap)*sign, -imageSize.width, 0, 0);
//        
//        let titleSize = titleLabel.bounds.size;
//        self.imageEdgeInsets = UIEdgeInsetsMake(-(titleSize.height+gap)*sign, 0, 0, -titleSize.width);
//    }
}
