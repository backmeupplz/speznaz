//
//  ChartState.swift
//  SpeznazDemo
//
//  Created by Nikita Kolmogorov on 2019-03-20.
//  Copyright © 2019 Nikita Kolmogorov. All rights reserved.
//

import UIKit

class ChartState {
    var bottom: CGFloat = 0.5
    var top: CGFloat = 1.0
    
    convenience init(_ bottom: CGFloat, _ top: CGFloat) {
        self.init()
        
        self.bottom = bottom
        self.top = top
    }
}
