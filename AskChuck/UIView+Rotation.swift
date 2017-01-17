//
//  UIView+Rotation.swift
//  AskChuck
//
//  Created by Litter Box Labs on 1/14/17.
//  Copyright © 2017 Chucklet Labs. All rights reserved.
//

import Foundation
import UIKit

// Constant used by this extension
let kAnimationKey = "rotation"

extension UIView {
    func startRotating(duration: Double = 1) {
        
        
        if self.layer.animation(forKey: kAnimationKey) == nil {
            
            let animationRotate = CABasicAnimation(keyPath: "transform.rotation")
            animationRotate.duration = duration
            animationRotate.repeatCount = Float.infinity
            animationRotate.fromValue = 0.0
            animationRotate.toValue = Float(M_PI * 2.0)
            self.layer.add(animationRotate, forKey: kAnimationKey)
        }
    }
    
    func stopRotating() {
        
        if self.layer.animation(forKey: kAnimationKey) != nil {
            self.layer.removeAnimation(forKey: kAnimationKey)
        }
    }
}

