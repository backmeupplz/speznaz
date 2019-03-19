//
//  ChartView.swift
//  SpeznazDemo
//
//  Created by Nikita Kolmogorov on 2019-03-16.
//  Copyright © 2019 Nikita Kolmogorov. All rights reserved.
//

import UIKit

class ChartView: UIView {
    
    // MARK: - Private Constants -
    
    struct Constants {
        static let navigateViewHeight: CGFloat = 45
        static let labelHeight: CGFloat = 16
        static let font = CTFontCreateWithName(UIFont.systemFont(ofSize: 1).fontName as CFString, 1, nil)
    }

    // MARK: - Properties -
    
    var chart: Chart! {
        didSet {
            compute()
            render()
        }
    }
    
    var topYValue: CGFloat!
    var bottomYValue: CGFloat!
    var topXValue: CGFloat!
    var bottomXValue: CGFloat!
    
    // MARK: - Public Functions -
    
    public func updateData() {
        compute()
        render()
    }
    
    // MARK: - Computation -
    
    func compute() {
        // Get values
        var allValues = Set<Int>()
        for columnName in chart.columnNames {
            guard let column = chart.columns[columnName] else {
                continue
            }
            allValues = allValues.union(column.values)
        }
        // Get top value
        var tempTopValue = 0;
        var tempBottomValue = allValues.first!
        for value in allValues {
            if value > tempTopValue {
                tempTopValue = value
            }
            if value < tempBottomValue {
                tempBottomValue = value
            }
        }
        topYValue = CGFloat(tempTopValue)
        bottomYValue = CGFloat(tempBottomValue)
        bottomYValue = bottomYValue - ((topYValue - bottomYValue) / 10.0)
        if (bottomYValue < 0) {
            bottomYValue = 0.0
        }
        // Setup X
        topXValue = CGFloat(chart.columns["x"]!.values.last!)
        bottomXValue = CGFloat(chart.columns["x"]!.values.first!)
    }
    
    // MARK: - Rendering -
    
    func render() {
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        addGrid()
    }
    
    func addGrid() {
        let chartHeight = frame.height - Constants.navigateViewHeight - Constants.labelHeight
        let segmentHeight = (chartHeight - Constants.labelHeight) / 5.0
        
        // Draw horizontal grid lines
        for i in 0 ..< 6 {
            let cgI = CGFloat(i)
            let from = CGPoint(x: 0, y: chartHeight - (cgI * segmentHeight))
            let to = CGPoint(x: frame.width, y: chartHeight - (cgI * segmentHeight))
            addLine(from: from, to: to)
        }
        // Draw charts
        for columnName in chart.columnNames {
            // Get config and values
            let xValues = chart.columns["x"]!.values
            let yValues = chart.columns[columnName]!.values
            let color = chart.colors[columnName]!.cgColor
            // Create path
            let path = UIBezierPath()
            for i in 0 ..< yValues.count {
                let x = CGFloat(xValues[i])
                let translatedX = ((x - bottomXValue) / (topXValue - bottomXValue)) * frame.width
                let y = CGFloat(yValues[i])
                let translatedY = chartHeight - (((y - bottomYValue) / (topYValue - bottomYValue)) * chartHeight)
                let coordinate = CGPoint(x: translatedX, y: translatedY)
                if (i == 0) {
                    path.move(to: coordinate)
                } else {
                    path.addLine(to: coordinate)
                }
            }
            // Draw line
            let chartLayer = CAShapeLayer()
            chartLayer.path = path.cgPath
            chartLayer.strokeColor = color
            chartLayer.fillColor = UIColor.clear.cgColor
            chartLayer.lineWidth = 3
            chartLayer.lineCap = .round
            layer.addSublayer(chartLayer)
        }
        // Draw horizontal grid lines titles
        for i in 0 ..< 7 {
            let cgI = CGFloat(i)
            let y = chartHeight - (cgI * segmentHeight) - Constants.labelHeight
            let text = "\(Int(floor(floor(chartHeight - (y + Constants.labelHeight)) / chartHeight * (topYValue - bottomYValue) + bottomYValue)))"
            addLabel(text: text, at: CGPoint(x: 0, y: y))
        }
    }
    
    func addLine(from: CGPoint, to: CGPoint) {
        let path = UIBezierPath()
        path.move(to: from)
        path.addLine(to: to)
        
        let lineLayer = CAShapeLayer()
        lineLayer.path = path.cgPath
        lineLayer.lineWidth = 1
        lineLayer.strokeColor = UIColor(red: 245, green: 244, blue: 245).cgColor
        layer.addSublayer(lineLayer)
    }
    
    func addLabel(text: String, at: CGPoint) {
        let textLayer = CATextLayer()
        textLayer.frame = CGRect(x: at.x, y: at.y, width: 400, height: Constants.labelHeight)
        textLayer.string = text
        textLayer.foregroundColor = UIColor(red: 168, green: 173, blue: 180).cgColor
        textLayer.alignmentMode = .left
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.font = Constants.font
        textLayer.fontSize = 12.0
        layer.addSublayer(textLayer)
    }
}
