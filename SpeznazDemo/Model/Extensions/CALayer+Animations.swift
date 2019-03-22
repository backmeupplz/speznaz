//
//  CALayer+Animations.swift
//  SpeznazDemo
//
//  Created by Nikita Kolmogorov on 2019-03-22.
//  Copyright © 2019 Nikita Kolmogorov. All rights reserved.
//

import UIKit

struct AnimationConstants {
    static let animationDuration: CFTimeInterval = 1
    static let animationMoveDistance: CGFloat = 30
}

extension CALayer {
    func move(up: Bool, fadeIn: Bool, removeOnCompletion: Bool, movesIn: Bool) {
        // Fade
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fromValue = fadeIn ? 0 : 1
        fadeAnimation.duration = AnimationConstants.animationDuration
        fadeAnimation.isRemovedOnCompletion = true
        add(fadeAnimation, forKey: "fadeOut")
        opacity = fadeIn ? 1 : 0
        // Move
        let moveAnimation = CABasicAnimation(keyPath: "position")
        let newPosition = CGPoint(x: position.x, y: up ? position.y + AnimationConstants.animationMoveDistance : position.y - AnimationConstants.animationMoveDistance)
        moveAnimation.fromValue = movesIn ? newPosition : position
        moveAnimation.toValue = movesIn ? position : newPosition
        moveAnimation.duration = AnimationConstants.animationDuration
        add(moveAnimation, forKey: "move")
        position = newPosition
        // Remove on completion
        if removeOnCompletion {
            moveAnimation.delegate = LayerRemover(for: self)
        }
    }
    
    func fade(fadeIn: Bool, removeOnCompletion: Bool) {
        // Fade
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fromValue = fadeIn ? 0 : 1
        fadeAnimation.duration = AnimationConstants.animationDuration
        fadeAnimation.isRemovedOnCompletion = true
        add(fadeAnimation, forKey: "fadeOut")
        opacity = fadeIn ? 1 : 0
        // Remove on completion
        if removeOnCompletion {
            fadeAnimation.delegate = LayerRemover(for: self)
        }
    }
}
