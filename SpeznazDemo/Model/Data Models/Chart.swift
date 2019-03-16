//
//  Chart.swift
//  SpeznazDemo
//
//  Created by Nikita Kolmogorov on 2019-03-15.
//  Copyright © 2019 Nikita Kolmogorov. All rights reserved.
//

import UIKit

class Column: Decodable {
    var name: String
    var values: [Int]
    
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

class Chart: Decodable {
    var columns: [String: [Int]]
    var types: [String: LineType]
    var names: [String: String]
    var colors: [String: UIColor]
    
    enum CodingKeys: CodingKey {
        case columns
        case types
        case names
        case colors
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        // Simple types
        types = try values.decode([String: LineType].self, forKey: .types)
        names = try values.decode([String: String].self, forKey: .names)
        // Colors
        let colorStringsMap = try values.decode([String: String].self, forKey: .colors)
        colors = colorStringsMap.mapValues { colorString in UIColor(hex: colorString)}
        // Columns
        let jsonColumns = try values.decode([Column].self, forKey: CodingKeys.columns)
        var mutableColumnsMap = [String: [Int]]()
        for column in jsonColumns {
            mutableColumnsMap[column.name] = column.values
        }
        columns = mutableColumnsMap
    }
}
