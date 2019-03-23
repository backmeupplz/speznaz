//
//  CALayer+Animations.swift
//  SpeznazDemo
//
//  Created by Nikita Kolmogorov on 2019-03-22.
//  Copyright © 2019 Nikita Kolmogorov. All rights reserved.
//

import UIKit

struct AnimationConstants {
    static let animationDuration: CFTimeInterval = 0.2
    static let animationMoveDistance: CGFloat = 30
}

extension CALayer {
    func move(up: Bool, fadeIn: Bool, removeOnCompletion: Bool, movesIn: Bool) {
        // Fade
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fromValue = fadeIn ? 0 : 1
        fadeAnimation.toValue = fadeIn ? 1 : 0
        fadeAnimation.duration = AnimationConstants.animationDuration
        fadeAnimation.isRemovedOnCompletion = true
        fadeAnimation.autoreverses = false
        add(fadeAnimation, forKey: "fadeOut")
        // Move
        let moveAnimation = CABasicAnimation(keyPath: "position")
        let newPosition = CGPoint(x: position.x, y: up ? position.y + AnimationConstants.animationMoveDistance : position.y - AnimationConstants.animationMoveDistance)
        moveAnimation.fromValue = movesIn ? newPosition : position
        moveAnimation.toValue = movesIn ? position : newPosition
        moveAnimation.duration = AnimationConstants.animationDuration
        moveAnimation.isRemovedOnCompletion = true
        moveAnimation.autoreverses = false
        // Remove on completion
        moveAnimation.delegate = LayerAnimationDelegate(for: self, removeOnCompletion: removeOnCompletion)
        add(moveAnimation, forKey: "move")
    }
    
    func fade(fadeIn: Bool, removeOnCompletion: Bool) {
        // Fade
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fromValue = fadeIn ? 0 : 1
        fadeAnimation.toValue = fadeIn ? 1 : 0
        fadeAnimation.duration = AnimationConstants.animationDuration
        fadeAnimation.isRemovedOnCompletion = true
        fadeAnimation.autoreverses = false
        // Remove on completion
        fadeAnimation.delegate = LayerAnimationDelegate(for: self, removeOnCompletion: removeOnCompletion)
        add(fadeAnimation, forKey: "fade")
    }
}
