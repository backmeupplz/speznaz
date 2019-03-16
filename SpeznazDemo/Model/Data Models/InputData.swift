//
//  InputData.swift
//  SpeznazDemo
//
//  Created by Nikita Kolmogorov on 2019-03-15.
//  Copyright © 2019 Nikita Kolmogorov. All rights reserved.
//

import UIKit

class InputData {
    
    // MARK: - Lazy loaded data -
    
    public static let data: InputData = {
        let parsedData = InputData()
        return parsedData
    }()
    
    // MARK: - Variables -
    
    var charts: [Chart] = []
    
    // MARK: - Initializer and it's functions -
    
    init() {
        // Get json
        guard let data = try? Data(contentsOf: URL(fileReferenceLiteralResourceName: "chart_data.json")) else {
            return
        }
        // Show me what you've got
        // (yes, my IQ is over 190, deal with it, I watch R&M) #irony
        //                 ___
        //            . -^   `--,
        //           /# =========`-_
        //          /# (--====___====\
        //         /#   .- --.  . --.|
        //        /##   |  * ) (   * ),
        //        |##   \    /\ \   / |
        //        |###   ---   \ ---  |
        //        |####      ___)    #|
        //        |######           ##|
        //         \##### ---------- /
        //          \####           (
        //           `\###          |
        //             \###         |
        //              \##        |
        //               \###.    .)
        //                `======/
        do {
            charts = try JSONDecoder().decode([Chart].self, from: data)
        } catch (let err) {
            print(err)
            
        }
        if let unwrappedCharts = try? JSONDecoder().decode([Chart].self, from: data) {
            charts = unwrappedCharts
        }
    }
}
