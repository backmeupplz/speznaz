//
//  LayerAnimationDelegate.swift
//  SpeznazDemo
//
//  Created by Nikita Kolmogorov on 2019-03-22.
//  Copyright © 2019 Nikita Kolmogorov. All rights reserved.
//

import UIKit

class LayerAnimationDelegate: NSObject, CAAnimationDelegate {
    private weak var layer: CALayer?
    private var removeOnCompletion: Bool!
    
    init(for layer: CALayer, removeOnCompletion: Bool) {
        self.layer = layer
        self.removeOnCompletion = removeOnCompletion
        super.init()
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if removeOnCompletion {
            layer?.removeFromSuperlayer()
        }
    }
}
