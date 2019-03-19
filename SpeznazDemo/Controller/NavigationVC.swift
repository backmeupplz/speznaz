//
//  NavigationVC.swift
//  SpeznazDemo
//
//  Created by Nikita Kolmogorov on 2019-03-14.
//  Copyright © 2019 Nikita Kolmogorov. All rights reserved.
//

import UIKit

class NavigationVC: UINavigationController {
    // MARK: - Status bar -
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Colors.mode == .night ? .lightContent : .default
    }
}
