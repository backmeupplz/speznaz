//
//  StatisticsDataSource.swift
//  SpeznazDemo
//
//  Created by Nikita Kolmogorov on 2019-03-16.
//  Copyright © 2019 Nikita Kolmogorov. All rights reserved.
//

import UIKit

class StatisticsDataSource: NSObject {
    
    // MARK: - Properties -
    
    let data = InputData.data
}

extension StatisticsDataSource: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.charts.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == data.charts.count ? 1 : data.charts[section].columnNames.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == data.charts.count {
            return switchColorModeCell(for: tableView, with: indexPath)
        } else {
            if (indexPath.row == 0) {
                return chartCell(for: tableView, with: indexPath)
            } else {
                return columnCell(for: tableView, with: indexPath)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Followers"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == 0) {
            return
        }
        let chart = data.charts[indexPath.section]
        let columnName = chart.columnNames[indexPath.row - 1]
        guard let cell = tableView.cellForRow(at: indexPath), let column = chart.columns[columnName] else {
            return
        }
        column.selected = true
        cell.accessoryType = .checkmark
        
        updateData(for: tableView, at: indexPath.section)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if (indexPath.row == 0) {
            return
        }
        let chart = data.charts[indexPath.section]
        let columnName = chart.columnNames[indexPath.row - 1]
        guard let cell = tableView.cellForRow(at: indexPath), let column = chart.columns[columnName] else {
            return
        }
        column.selected = false
        cell.accessoryType = .none
        
        updateData(for: tableView, at: indexPath.section)
    }
    
    // MARK: - Cell Getters -
    
    func switchColorModeCell(for tableView: UITableView, with indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: String(describing: SwitchColorModeCell.self), for: indexPath)
    }
    
    func columnCell(for tableView: UITableView, with indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ColumnCell.self), for: indexPath) as? ColumnCell else {
            return UITableViewCell()
        }
        
        // Get data
        let chart = data.charts[indexPath.section]
        let columnName = chart.columnNames[indexPath.row - 1]
        guard let column = chart.columns[columnName] else {
            return UITableViewCell()
        }
        
        // Configure cell
        cell.title.text = columnName
        cell.coloredSquare.backgroundColor = chart.colors[columnName]
        cell.accessoryType = column.selected ? .checkmark : .none
        
        return cell
    }
    
    func chartCell(for tableView: UITableView, with indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ChartCell.self), for: indexPath) as? ChartCell else {
            return UITableViewCell()
        }
        
        // Get data
        let chart = data.charts[indexPath.section]
        
        // Configure cell
        cell.chartView.chart = chart
        
        return cell
    }
    
    // MARK: - Extra Functions -
    
    func updateData(for tableView: UITableView, at section: Int) {
        guard let chartCell = tableView.cellForRow(at: IndexPath(row: 0, section: section)) as? ChartCell else {
            return
        }
        chartCell.chartView.updateData()
    }
}

extension StatisticsDataSource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section < data.charts.count && indexPath.row == 0) {
            return 350
        }
        return 43.5
    }
}
