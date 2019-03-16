//
//  Column.swift
//  SpeznazDemo
//
//  Created by Nikita Kolmogorov on 2019-03-16.
//  Copyright © 2019 Nikita Kolmogorov. All rights reserved.
//

import Foundation

class Column: Decodable {
    var name: String
    var values: [Int]
    var selected = true
    
    required init(from decoder: Decoder) throws {
        var data = try decoder.unkeyedContainer()
        name = try data.decode(String.self)
        var tempValues = [Int]()
        while !data.isAtEnd {
            let value = try data.decode(Int.self)
            tempValues.append(value)
        }
        values = tempValues
    }
}
