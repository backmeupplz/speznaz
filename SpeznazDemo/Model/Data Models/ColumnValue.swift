//
//  ColumnValue.swift
//  SpeznazDemo
//
//  Created by Nikita Kolmogorov on 2019-03-16.
//  Copyright © 2019 Nikita Kolmogorov. All rights reserved.
//

import Foundation

enum ColumnValue: Decodable {
    enum CodingKeys: String, CodingKey {
        case string, int
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let stringValue = try container.decodeIfPresent(String.self, forKey: .string) {
            self = .name(stringValue)
        } else if let intValue = try container.decodeIfPresent(Int.self, forKey: .int) {
            self = .value(intValue)
        }
        throw DecodingError.invalidColumnData
    }
    
    case name(String)
    case value(Int)
}
