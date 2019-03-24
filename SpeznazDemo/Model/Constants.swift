//
//  Constants.swift
//  SpeznazDemo
//
//  Created by Nikita Kolmogorov on 2019-03-22.
//  Copyright © 2019 Nikita Kolmogorov. All rights reserved.
//

import UIKit

struct Constants {
    static let navigationViewHeight: CGFloat = 45
    static let labelHeight: CGFloat = 16
    static let font = CTFontCreateWithName(UIFont.systemFont(ofSize: 1).fontName as CFString, 1, nil)
    static let boldFont = CTFontCreateWithName(UIFont.systemFont(ofSize: 1, weight: .bold).fontName as CFString, 1, nil)
    static let spacing: CGFloat = 16
    static let arrowWidth: CGFloat = 10
    static let arrowLineWidth: CGFloat = 2
    
    static let arrowImageHeight: CGFloat = 10
    static let arrowImageWidth: CGFloat = 4
    
    static let arrowTouchExtraWidth: CGFloat = 5
    
    static let minDiffInBottomAndTop: CGFloat = 0.1
    
    static let chartLineWidth: CGFloat = 2
    
    static let timeLabelWidth: CGFloat = 60
}
