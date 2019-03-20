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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateAllRows()
    }
    
    // MARK: - Private Functions -
    
    func selectAllRows() {
        for section in 0 ..< tableView.numberOfSections - 1 {
            for row in 1 ..< tableView.numberOfRows(inSection: section) {
                tableView.selectRow(at: IndexPath(row: row, section: section), animated: false, scrollPosition: .none)
            }
        }
    }
    
    func updateAllRows() {
        for section in 0 ..< tableView.numberOfSections - 1 {
            if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: section)) as? ChartCell {
                cell.chartView.updateData()
            }
        }
    }
}
