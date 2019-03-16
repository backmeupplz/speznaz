//
//  UserDefaults.swift
//  SpeznazDemo
//
//  Created by Nikita Kolmogorov on 2019-03-14.
//  Copyright © 2019 Nikita Kolmogorov. All rights reserved.
//

import UIKit

enum StorageKey: String {
    case colorMode
}

class Storage {
    public static func get(by key: StorageKey) -> String? {
       return UserDefaults.standard.value(forKey: key.rawValue) as? String
    }
    
    public static func set(value: Any?, for key: StorageKey) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
        UserDefaults.standard.synchronize()
    }
}
