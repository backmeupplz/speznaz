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
        static let navigationViewHeight: CGFloat = 45
        static let labelHeight: CGFloat = 16
        static let font = CTFontCreateWithName(UIFont.systemFont(ofSize: 1).fontName as CFString, 1, nil)
        static let spacing: CGFloat = 16
        static let arrowWidth: CGFloat = 10
        static let arrowLineWidth: CGFloat = 2
        
        static let arrowImageHeight: CGFloat = 16
        static let arrowImageWidth: CGFloat = 3
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
        // Setup X
        topXValue = CGFloat(chart.columns["x"]!.values.last!)
        bottomXValue = CGFloat(chart.columns["x"]!.values.first!)
    }
    
    // MARK: - Rendering -
    
    func render() {
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        addGrid()
        drawNavigationView()
    }
    
    func addGrid() {
        let chartHeight = frame.height - Constants.navigationViewHeight - Constants.labelHeight
        let segmentHeight = (chartHeight - Constants.labelHeight) / 5.0
        
        // Draw horizontal grid lines
        for i in 0 ..< 6 {
            let cgI = CGFloat(i)
            let from = CGPoint(x: 0, y: chartHeight - (cgI * segmentHeight))
            let to = CGPoint(x: frame.width, y: chartHeight - (cgI * segmentHeight))
            addLine(from: from, to: to)
        }
        // Draw charts
        var elevatedBottomYValue = bottomYValue - ((topYValue - bottomYValue) / 10.0)
        if (elevatedBottomYValue < 0) {
            elevatedBottomYValue = 0.0
        }
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
                let translatedY = chartHeight - (((y - elevatedBottomYValue) / (topYValue - elevatedBottomYValue)) * chartHeight)
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
            chartLayer.lineWidth = 2
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
    
    func add(rect: CGRect, color: UIColor) {
        let rectLayer = CAShapeLayer()
        rectLayer.path = UIBezierPath(rect: rect).cgPath
        rectLayer.fillColor = color.cgColor
        layer.addSublayer(rectLayer)
    }
    
    func drawNavigationView() {
        // Draw navigate view
        let strokeWidth = CGFloat(2)
        for columnName in chart.columnNames {
            // Get config and values
            let xValues = chart.columns["x"]!.values
            let yValues = chart.columns[columnName]!.values
            let color = chart.colors[columnName]!.cgColor
            // Create path
            let path = UIBezierPath()
            for i in 0 ..< yValues.count {
                let x = CGFloat(xValues[i])
                let translatedX = ((x - bottomXValue) / (topXValue - bottomXValue)) * (frame.width - (strokeWidth * 2)) + strokeWidth
                let y = CGFloat(yValues[i])
                let translatedY = frame.height - strokeWidth - (((y - bottomYValue) / (topYValue - bottomYValue)) * (Constants.navigationViewHeight - (strokeWidth * 2)))
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
            chartLayer.lineWidth = strokeWidth
            chartLayer.lineCap = .round
            layer.addSublayer(chartLayer)
        }
        // Draw left shaded view
        let leftShadedViewRect = CGRect(x: 0,
                                        y: frame.height - Constants.navigationViewHeight,
                                        width: frame.width * chart.state.bottom,
                                        height: Constants.navigationViewHeight)
        let shadedViewColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.03)
        add(rect: leftShadedViewRect, color: shadedViewColor)
        // Draw right shaded view
        let rightShadedViewRect = CGRect(x: frame.width * chart.state.top,
                                         y: frame.height - Constants.navigationViewHeight,
                                         width: frame.width - (frame.width * chart.state.top),
                                         height: Constants.navigationViewHeight)
        add(rect: rightShadedViewRect, color: shadedViewColor)
        // Draw left arrow view
        let arrowColor = UIColor(red: 195, green: 206, blue: 217, alpha: 0.8)
        let leftArrowRect = CGRect(x: frame.width * chart.state.bottom,
                                   y: frame.height - Constants.navigationViewHeight - Constants.arrowLineWidth,
                                   width: Constants.arrowWidth,
                                   height: Constants.navigationViewHeight + (Constants.arrowLineWidth * 2))
        add(rect: leftArrowRect, color: arrowColor)
        // Draw right arrow view
        let rightArrowRect = CGRect(x: frame.width * chart.state.top - Constants.arrowWidth,
                                    y: frame.height - Constants.navigationViewHeight - Constants.arrowLineWidth,
                                    width: Constants.arrowWidth,
                                    height: Constants.navigationViewHeight + (Constants.arrowLineWidth * 2))
        add(rect: rightArrowRect, color: arrowColor)
        // Draw bottom arrow view
        let arrowViewWidth = rightArrowRect.minX - (leftArrowRect.minX + leftArrowRect.width)
        let bottomArrowRect = CGRect(x: frame.width * chart.state.bottom + Constants.arrowWidth,
                                     y: frame.height - Constants.navigationViewHeight - Constants.arrowLineWidth,
                                     width: arrowViewWidth,
                                     height: Constants.arrowLineWidth)
        add(rect: bottomArrowRect, color: arrowColor)
        // Draw top arrow view
        let topArrowRect = CGRect(x: frame.width * chart.state.bottom + Constants.arrowWidth,
                                  y: frame.height,
                                  width: arrowViewWidth,
                                  height: Constants.arrowLineWidth)
        add(rect: topArrowRect, color: arrowColor)
        // Draw left arrow
        let leftArrowPath = UIBezierPath()
        leftArrowPath.move(to: CGPoint(x: leftArrowRect.minX + (leftArrowRect.width / 2) + (Constants.arrowImageWidth / 2),
                                       y: leftArrowRect.minY + (leftArrowRect.height / 2) - (Constants.arrowImageHeight / 2)))
        leftArrowPath.addLine(to: CGPoint(x: leftArrowRect.minX + (leftArrowRect.width / 2) - (Constants.arrowImageWidth / 2),
                                          y: leftArrowRect.minY + (leftArrowRect.height / 2)))
        leftArrowPath.addLine(to: CGPoint(x: leftArrowRect.minX + (leftArrowRect.width / 2) + (Constants.arrowImageWidth / 2),
                                          y: leftArrowRect.minY + (leftArrowRect.height / 2) + (Constants.arrowImageHeight / 2)))
        let leftArrowLayer = CAShapeLayer()
        leftArrowLayer.path = leftArrowPath.cgPath
        leftArrowLayer.strokeColor = UIColor.white.cgColor
        leftArrowLayer.fillColor = UIColor.clear.cgColor
        leftArrowLayer.lineWidth = 2
        leftArrowLayer.lineCap = .round
        layer.addSublayer(leftArrowLayer)
        // Draw right arrow
        let rightArrowPath = UIBezierPath()
        rightArrowPath.move(to: CGPoint(x: rightArrowRect.minX + (rightArrowRect.width / 2) - (Constants.arrowImageWidth / 2),
                                        y: rightArrowRect.minY + (rightArrowRect.height / 2) - (Constants.arrowImageHeight / 2)))
        rightArrowPath.addLine(to: CGPoint(x: rightArrowRect.minX + (rightArrowRect.width / 2) + (Constants.arrowImageWidth / 2),
                                           y: rightArrowRect.minY + (rightArrowRect.height / 2)))
        rightArrowPath.addLine(to: CGPoint(x: rightArrowRect.minX + (rightArrowRect.width / 2) - (Constants.arrowImageWidth / 2),
                                           y: rightArrowRect.minY + (rightArrowRect.height / 2) + (Constants.arrowImageHeight / 2)))
        let rightArrowLayer = CAShapeLayer()
        rightArrowLayer.path = rightArrowPath.cgPath
        rightArrowLayer.strokeColor = UIColor.white.cgColor
        rightArrowLayer.fillColor = UIColor.clear.cgColor
        rightArrowLayer.lineWidth = 2
        rightArrowLayer.lineCap = .round
        layer.addSublayer(rightArrowLayer)
    }
}
