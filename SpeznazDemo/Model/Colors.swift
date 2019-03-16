//
//  Colors.swift
//  SpeznazDemo
//
//  Created by Nikita Kolmogorov on 2019-03-14.
//  Copyright © 2019 Nikita Kolmogorov. All rights reserved.
//

import UIKit

enum ColorMode: String {
    case night
    case day
}

class Colors {
    public static var mode: ColorMode {
        get {
            guard let storageColorMode = Storage.get(by: .colorMode) else {
                return .day
            }
            return ColorMode(rawValue: storageColorMode) ?? .day
        }
        set {
            Storage.set(value: newValue.rawValue, for:.colorMode)
            update()
        }
    }
    
    public static func update() {
        // Get mode
        let mode = self.mode
        
        // Constants
        let darkBlue = UIColor(red: 30, green: 42, blue: 55, alpha: 1)
        let lightWhite = UIColor(red: 254, green: 254, blue: 254, alpha: 1)
        
        // Apply settings
        UITableView.appearance().backgroundColor = mode == .night ?
            UIColor(red: 23, green: 31, blue: 40, alpha: 1) :
            UIColor(red: 237, green: 236, blue: 242, alpha: 1)
        UIButton.appearance().tintColor = mode == .night ?
            UIColor(red: 21, green: 134, blue: 255, alpha: 1) :
            UIColor(red: 0, green: 115, blue: 225, alpha: 1)
        UITableViewCell.appearance().backgroundColor = mode == .night ?
            darkBlue : lightWhite
        UITableView.appearance().separatorColor = mode == .night ?
            UIColor(red: 19, green: 25, blue: 32, alpha: 1) :
            UIColor(red: 193, green: 192, blue: 197, alpha: 1)
        UINavigationBar.appearance().barTintColor = mode == .night ?
            darkBlue : lightWhite
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: mode == .night ?
                UIColor(red: 254, green: 253, blue: 254) :
                UIColor.black
        ]
        UILabel.appearance().textColor = mode == .night ?
            UIColor.white : UIColor.black
        
        // Hacky way to refresh the app
        refreshAppearance()
    }
    
    static func refreshAppearance() {
        UIApplication.shared.windows.forEach { window in
            window.subviews.forEach { view in
                view.removeFromSuperview()
                window.addSubview(view)
            }
        }
        
        UIApplication.shared.windows[0].rootViewController?.setNeedsStatusBarAppearanceUpdate()
    }
}
