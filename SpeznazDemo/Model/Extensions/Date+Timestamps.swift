//
//  Date+Timestamps.swift
//  SpeznazDemo
//
//  Created by Nikita Kolmogorov on 2019-03-23.
//  Copyright © 2019 Nikita Kolmogorov. All rights reserved.
//

import Foundation


extension Date {
    var millisecondsSince1970: Int {
        return Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds: Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}
