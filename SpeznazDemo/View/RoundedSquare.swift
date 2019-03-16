//
//  RoundedSquare.swift
//  SpeznazDemo
//
//  Created by Nikita Kolmogorov on 2019-03-16.
//  Copyright © 2019 Nikita Kolmogorov. All rights reserved.
//

import UIKit

class RoundedSquare: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.clipsToBounds = true
        self.layer.cornerRadius = 4.0
    }
}
