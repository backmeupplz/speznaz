//
//  MaxMin.swift
//  SpeznazDemo
//
//  Created by Nikita Kolmogorov on 2019-03-21.
//  Copyright © 2019 Nikita Kolmogorov. All rights reserved.
//

import UIKit

class MaxMin {
    var max: CGFloat!
    var min: CGFloat!
    
    var empty: Bool {
        get {
            return max == 0 && min == 0
        }
    }
    
    var diff: CGFloat {
        get {
            return max - min
        }
    }
    
    convenience init(_ max: CGFloat, _ min: CGFloat) {
        self.init()
        
        self.max = max
        self.min = min
    }
}
