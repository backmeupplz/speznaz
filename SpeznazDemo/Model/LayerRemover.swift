//
//  LayerRemover.swift
//  SpeznazDemo
//
//  Created by Nikita Kolmogorov on 2019-03-22.
//  Copyright © 2019 Nikita Kolmogorov. All rights reserved.
//

import UIKit

class LayerRemover: NSObject, CAAnimationDelegate {
    private weak var layer: CALayer?
    
    init(for layer: CALayer) {
        self.layer = layer
        super.init()
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        layer?.removeFromSuperlayer()
    }
}
