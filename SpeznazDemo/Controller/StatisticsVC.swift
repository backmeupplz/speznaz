//
//  StatisticsVC.swift
//  SpeznazDemo
//
//  Created by Nikita Kolmogorov on 2019-03-14.
//  Copyright © 2019 Nikita Kolmogorov. All rights reserved.
//

import UIKit

class StatisticsVC: UITableViewController {
    
    // MARK: - Properties -
    
    let dataSource = StatisticsDataSource()
    
    // MARK: - VC Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        
        selectAllRows()
    }
    
    // MARK: - Private Functions -
    
    func selectAllRows() {
        for section in 0 ..< tableView.numberOfSections {
            for row in 0 ..< tableView.numberOfRows(inSection: section) {
                tableView.selectRow(at: IndexPath(row: row, section: section), animated: false, scrollPosition: .none)
            }
        }
    }
}
