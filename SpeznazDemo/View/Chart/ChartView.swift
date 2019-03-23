//
//  ChartView.swift
//  SpeznazDemo
//
//  Created by Nikita Kolmogorov on 2019-03-16.
//  Copyright © 2019 Nikita Kolmogorov. All rights reserved.
//

import UIKit

enum PannedView: Int {
    case leftArrow
    case rightArrow
    case navigationView
    case chartView
}

class ChartView: UIView {
    // MARK: - Properties -
    
    var chart: Chart! {
        didSet {
            selectedColumnsNames = chart.columnNames
                .filter { chart.columns[$0]?.selected ?? false }
            updateData(animated: false)
        }
    }
    var selectedColumnsNames = [String]()
    var selectedNavigationColumnsNames = [String]()
    
    var localOldMaxMinY = MaxMin(0, 0)
    var localMaxMinY = MaxMin(0, 0)
    
    var oldMaxMinY = MaxMin(0, 0)
    var maxMinY = MaxMin(0, 0)
    var maxMinX = MaxMin(0, 0)
    var yWentUp = true
    var yChanged = false
    
    var chartWidth = CGFloat(0)
    
    var panGR: UIPanGestureRecognizer!
    
    var pannedView: PannedView?
    var pannedState: ChartState!
    
    var chartScrollLayer: CAScrollLayer!
    var chartScrollContentLayer: CALayer!
    
    var navigationChartLayer: CALayer!
    
    var leftArrowRect: CGRect!
    var rightArrowRect: CGRect!
    var scrollRect: CGRect!
    
    var colorMode: ColorMode!
    
    var chartLayers = [String: CAShapeLayer]()
    var horizontalGridLinesLayers = [CAShapeLayer]()
    var horizontalGridTitlesLayers = [CATextLayer]()
    
    var navigationViewChartLayers = [String: CAShapeLayer]()
    var navigationViewRestLayers = [CALayer]()
    
    var chartHeight: CGFloat!
    var segmentHeight: CGFloat!
    
    // MARK: - View Life Cycle -
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addPanGR()
    }
    
    // MARK: - Public Functions -
    
    public func updateData(animated: Bool = true) {
        if !animated {
            layer.sublayers?.forEach { $0.removeFromSuperlayer() }
            chartScrollContentLayer?.sublayers?.forEach { $0.removeFromSuperlayer() }
        }
        colorMode = Colors.mode
        compute()
        render(animated: animated)
    }
    
    // MARK: - Computation -
    
    func compute() {
        // Get values
        var allValues = Set<Int>()
        for columnName in chart.columnNames {
            guard let column = chart.columns[columnName], column.selected else {
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
        // Get local values
        var localAllValues = Set<Int>()
        for columnName in chart.columnNames {
            guard let column = chart.columns[columnName], column.selected else {
                continue
            }
            let topIndex = CGFloat(column.values.count - 1)
            let startIndex = Int(floor(topIndex * chart.state.bottom))
            let endIndex = Int(ceil(topIndex * chart.state.top))
            localAllValues = localAllValues.union(column.values[startIndex...endIndex])
        }
        // Get top value
        var tempLocalTopValue = 0;
        var tempLocalBottomValue = allValues.first!
        for value in localAllValues {
            if value > tempLocalTopValue {
                tempLocalTopValue = value
            }
            if value < tempLocalBottomValue {
                tempLocalBottomValue = value
            }
        }
        // Save value for later
        oldMaxMinY = maxMinY
        localOldMaxMinY = localMaxMinY
        // Setup Y
        maxMinY = MaxMin(CGFloat(tempTopValue), CGFloat(tempBottomValue))
        localMaxMinY = MaxMin(CGFloat(tempLocalTopValue), CGFloat(tempLocalBottomValue))
        // Setup X
        maxMinX = MaxMin(CGFloat(chart.columns["x"]!.values.last!),
                         CGFloat(chart.columns["x"]!.values.first!))
        // Calculate if y went up
        yWentUp = localOldMaxMinY.diff > localMaxMinY.diff
        yChanged = localOldMaxMinY.diff != localMaxMinY.diff
        // Calculate dimensions
        chartHeight = frame.height - Constants.navigationViewHeight - (Constants.labelHeight * 2)
        segmentHeight = (chartHeight - Constants.labelHeight) / 5.0
        // Calculate chart properties
        chartWidth = frame.width / chart.state.diff
    }
    
    // MARK: - Rendering -
    
    func render(animated: Bool) {
        drawGrid(animated: animated)
        drawCharts(animated: animated)
        drawGridTitles(animated: animated)
        drawNavigationViewCharts(animated: animated)
        drawNavigationView()
    }
    
    func drawGrid(animated: Bool) {
        // Remove horizontal grid lines
        for line in horizontalGridLinesLayers {
            if animated && yChanged {
                line.move(up: yWentUp,
                          fadeIn: false,
                          removeOnCompletion: true,
                          movesIn: false)
            } else {
                line.removeFromSuperlayer()
            }
        }
        horizontalGridLinesLayers = []
        // Draw horizontal grid lines
        for i in 0 ..< 6 {
            let cgI = CGFloat(i)
            let from = CGPoint(x: 0, y: chartHeight - (cgI * segmentHeight))
            let to = CGPoint(x: frame.width, y: chartHeight - (cgI * segmentHeight))
            let line = addLine(from: from,
                               to: to,
                               color: colorMode == .day ?
                                UIColor(red: 245, green: 244, blue: 245) :
                                UIColor(red: 26, green: 35, blue: 46))
            horizontalGridLinesLayers.append(line)
            if animated && yChanged {
                line.move(up: yWentUp,
                          fadeIn: true,
                          removeOnCompletion: false,
                          movesIn: true)
            }
        }
    }
    
    func drawGridTitles(animated: Bool) {
        // Remove horizontal grid lines titles
        for title in horizontalGridTitlesLayers {
            if animated && yChanged {
                title.move(up: yWentUp,
                           fadeIn: false,
                           removeOnCompletion: true,
                           movesIn: false)
            } else {
                title.removeFromSuperlayer()
            }
        }
        horizontalGridTitlesLayers = []
        // Draw horizontal grid lines titles
        for i in 0 ..< 7 {
            let cgI = CGFloat(i)
            let y = chartHeight - (cgI * segmentHeight) - Constants.labelHeight
            let result = floor(chartHeight - (y + Constants.labelHeight)) / chartHeight * localMaxMinY.diff + localMaxMinY.min
            let flooredResult = floor(result)
            let text = "\(Int(flooredResult))"
            let label = addLabel(text: text, at: CGPoint(x: 0, y: y), color: colorMode == .day ?
                UIColor(red: 168, green: 173, blue: 180) :
                UIColor(red: 76, green: 91, blue: 107))
            horizontalGridTitlesLayers.append(label)
            if animated && yChanged {
                label.move(up: yWentUp,
                          fadeIn: true,
                          removeOnCompletion: false,
                          movesIn: true)
            }
        }
    }
    
    func drawCharts(animated: Bool) {
        // Add scroll layer
        let scrollLayer = chartScrollLayer ?? CAScrollLayer()
        chartScrollLayer = scrollLayer
        let contentLayer = chartScrollContentLayer ?? CALayer()
        if chartScrollContentLayer == nil {
            chartScrollLayer.addSublayer(contentLayer)
        }
        chartScrollContentLayer = contentLayer
        
        scrollRect = CGRect(x: 0,
                            y: 0,
                            width: frame.width,
                            height: chartHeight)
        scrollLayer.frame = scrollRect
        contentLayer.frame = CGRect(x: 0,
                                     y: 0,
                                     width: chartWidth,
                                     height: chartHeight)
        layer.addSublayer(chartScrollLayer)
        
        // Scroll
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        scrollLayer.scroll(to: CGPoint(x: chart.state.bottom * chartWidth, y: 0))
        CATransaction.commit()
        
        // Draw charts
        var elevatedBottomYValue = localMaxMinY.min - (localMaxMinY.diff / 10.0)
        if (elevatedBottomYValue < 0) {
            elevatedBottomYValue = 0.0
        }
        for columnName in chart.columnNames {
            guard let column = chart.columns[columnName] else {
                continue
            }
            // Modify selection
            let wasSelected = selectedColumnsNames.contains(columnName)
            if wasSelected && !column.selected {
                selectedColumnsNames = selectedColumnsNames.filter { $0 != columnName }
            } else if !wasSelected && column.selected {
                selectedColumnsNames.append(columnName)
            }
            // Get config and values
            let xValues = chart.columns["x"]!.values
            let yValues = chart.columns[columnName]!.values
            let color = chart.colors[columnName]!.cgColor
            // Create path
            let path = UIBezierPath()
            for i in 0 ..< yValues.count {
                let x = CGFloat(xValues[i])
                let translatedX = ((x - maxMinX.min) / maxMinX.diff) * chartWidth
                let y = CGFloat(yValues[i])
                let translatedY = chartHeight - (((y - elevatedBottomYValue) / (localMaxMinY.max - elevatedBottomYValue)) * chartHeight)
                let coordinate = CGPoint(x: translatedX, y: translatedY)
                if (i == 0) {
                    path.move(to: coordinate)
                } else {
                    path.addLine(to: coordinate)
                }
            }
            let oldPath = UIBezierPath()
            if !wasSelected && localOldMaxMinY.diff > 0 {
                var oldElevatedBottomYValue = localOldMaxMinY.min - (localOldMaxMinY.diff / 10.0)
                if (oldElevatedBottomYValue < 0) {
                    oldElevatedBottomYValue = 0.0
                }
                for i in 0 ..< yValues.count {
                    let x = CGFloat(xValues[i])
                    let translatedX = ((x - maxMinX.min) / maxMinX.diff) * chartWidth
                    let y = CGFloat(yValues[i])
                    let translatedY = chartHeight - (((y - oldElevatedBottomYValue) / (localOldMaxMinY.max - oldElevatedBottomYValue)) * chartHeight)
                    let coordinate = CGPoint(x: translatedX, y: translatedY)
                    if (i == 0) {
                        oldPath.move(to: coordinate)
                    } else {
                        oldPath.addLine(to: coordinate)
                    }
                }
            }
            // Draw line
            let chartLayer = chartLayers[columnName] ?? CAShapeLayer()
            
            if animated && wasSelected && column.selected {
                let animation = CABasicAnimation(keyPath: "path")
                animation.fromValue = chartLayer.path
                animation.toValue = path.cgPath
                animation.duration = AnimationConstants.animationDuration
                animation.isRemovedOnCompletion = true
                chartLayer.add(animation, forKey: "animatePath")
            } else if animated && !wasSelected && column.selected {
                chartLayer.fade(fadeIn: true, removeOnCompletion: false)
                chartLayer.path = oldPath.cgPath
                let animation = CABasicAnimation(keyPath: "path")
                animation.fromValue = chartLayer.path
                animation.toValue = path.cgPath
                animation.duration = AnimationConstants.animationDuration
                animation.isRemovedOnCompletion = true
                chartLayer.add(animation, forKey: "animatePath")
            } else if animated && wasSelected && !column.selected {
                chartLayer.fade(fadeIn: false, removeOnCompletion: true)
                let animation = CABasicAnimation(keyPath: "path")
                animation.fromValue = chartLayer.path
                animation.toValue = path.cgPath
                animation.duration = AnimationConstants.animationDuration
                animation.isRemovedOnCompletion = true
                chartLayer.add(animation, forKey: "animatePath")
            }
            chartLayer.path = path.cgPath
            chartLayer.strokeColor = color
            chartLayer.fillColor = UIColor.clear.cgColor
            chartLayer.lineWidth = Constants.chartLineWidth
            chartLayer.lineCap = .round
            if column.selected {
                contentLayer.addSublayer(chartLayer)
            } else if !animated {
                chartLayer.removeFromSuperlayer()
            }
            chartLayers[columnName] = chartLayer
        }
    }
    
    func drawNavigationViewCharts(animated: Bool) {
        // Create navigation view layer
        let contentLayer = navigationChartLayer ?? CALayer()
        if navigationChartLayer == nil {
            layer.addSublayer(contentLayer)
        }
        navigationChartLayer = contentLayer
        contentLayer.frame = CGRect(x: 0,
                                    y: frame.height - Constants.navigationViewHeight,
                                    width: frame.width,
                                    height: Constants.navigationViewHeight)
        contentLayer.bounds = CGRect(x: 0, y: 0, width: contentLayer.frame.width, height: contentLayer.frame.height)
        contentLayer.masksToBounds = true
        // Remove unselected charts
        for columnName in navigationViewChartLayers.keys {
            if let column = chart.columns[columnName], !column.selected {
                navigationViewChartLayers[columnName]?.removeFromSuperlayer()
                navigationViewChartLayers[columnName] = nil
            }
        }
        for columnName in chart.columnNames {
            guard let column = chart.columns[columnName] else {
                continue
            }
            // Modify selection
            let wasSelected = selectedNavigationColumnsNames.contains(columnName)
            if wasSelected && !column.selected {
                selectedNavigationColumnsNames = selectedNavigationColumnsNames.filter { $0 != columnName }
            } else if !wasSelected && column.selected {
                selectedNavigationColumnsNames.append(columnName)
            }
            // Get config and values
            let xValues = chart.columns["x"]!.values
            let yValues = chart.columns[columnName]!.values
            let color = chart.colors[columnName]!.cgColor
            // Create path
            let path = UIBezierPath()
            for i in 0 ..< yValues.count {
                let x = CGFloat(xValues[i])
                let translatedX = ((x - maxMinX.min) / maxMinX.diff) * (frame.width - (Constants.chartLineWidth * 2)) + Constants.chartLineWidth
                let y = CGFloat(yValues[i])
                let translatedY = Constants.navigationViewHeight - Constants.chartLineWidth - (((y - maxMinY.min) / maxMinY.diff) * (Constants.navigationViewHeight - (Constants.chartLineWidth * 2)))
                let coordinate = CGPoint(x: translatedX, y: translatedY)
                if (i == 0) {
                    path.move(to: coordinate)
                } else {
                    path.addLine(to: coordinate)
                }
            }
            let oldPath = UIBezierPath()
            if !wasSelected && oldMaxMinY.diff > 0 {
                for i in 0 ..< yValues.count {
                    let x = CGFloat(xValues[i])
                    let translatedX = ((x - maxMinX.min) / maxMinX.diff) * (frame.width - (Constants.chartLineWidth * 2)) + Constants.chartLineWidth
                    let y = CGFloat(yValues[i])
                    let translatedY = Constants.navigationViewHeight - Constants.chartLineWidth - (((y - oldMaxMinY.min) / oldMaxMinY.diff) * (Constants.navigationViewHeight - (Constants.chartLineWidth * 2)))
                    let coordinate = CGPoint(x: translatedX, y: translatedY)
                    if (i == 0) {
                        oldPath.move(to: coordinate)
                    } else {
                        oldPath.addLine(to: coordinate)
                    }
                }
            }
            // Draw line
            let chartLayer = navigationViewChartLayers[columnName] ?? CAShapeLayer()
            
            if animated && wasSelected && column.selected {
                let animation = CABasicAnimation(keyPath: "path")
                animation.fromValue = chartLayer.path
                animation.toValue = path.cgPath
                animation.duration = AnimationConstants.animationDuration
                animation.isRemovedOnCompletion = true
                chartLayer.add(animation, forKey: "animatePath")
            } else if animated && !wasSelected && column.selected {
                chartLayer.fade(fadeIn: true, removeOnCompletion: false)
            } else if animated && wasSelected && !column.selected {
                chartLayer.fade(fadeIn: false, removeOnCompletion: true)
            }
            chartLayer.path = path.cgPath
            chartLayer.strokeColor = color
            chartLayer.fillColor = UIColor.clear.cgColor
            chartLayer.lineWidth = Constants.chartLineWidth
            chartLayer.lineCap = .round
            if column.selected {
                contentLayer.addSublayer(chartLayer)
            } else if !animated {
                chartLayer.removeFromSuperlayer()
            }
            navigationViewChartLayers[columnName] = chartLayer
        }
    }
    
    func drawNavigationView() {
        // Clean up
        for layer in navigationViewRestLayers {
            layer.removeFromSuperlayer()
        }
        navigationViewRestLayers = []
        // Draw left shaded view
        let leftShadedViewRect = CGRect(x: 0,
                                        y: frame.height - Constants.navigationViewHeight,
                                        width: frame.width * chart.state.bottom,
                                        height: Constants.navigationViewHeight)
        let shadedViewColor = colorMode == .day ?
            UIColor(red: 0, green: 0, blue: 0, alpha: 0.03) :
            UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        navigationViewRestLayers.append(add(rect: leftShadedViewRect, color: shadedViewColor))
        // Draw right shaded view
        let rightShadedViewRect = CGRect(x: frame.width * chart.state.top,
                                         y: frame.height - Constants.navigationViewHeight,
                                         width: frame.width - (frame.width * chart.state.top),
                                         height: Constants.navigationViewHeight)
        navigationViewRestLayers.append(add(rect: rightShadedViewRect, color: shadedViewColor))
        // Draw left arrow view
        let arrowColor = colorMode == .day ?
            UIColor(red: 195, green: 206, blue: 217, alpha: 0.8) :
            UIColor(red: 46, green: 61, blue: 79, alpha: 0.8)
        leftArrowRect = CGRect(x: frame.width * chart.state.bottom,
                                   y: frame.height - Constants.navigationViewHeight - Constants.arrowLineWidth,
                                   width: Constants.arrowWidth,
                                   height: Constants.navigationViewHeight + (Constants.arrowLineWidth * 2))
        navigationViewRestLayers.append(add(roundedRect: leftArrowRect, color: arrowColor, by: [.bottomLeft, .topLeft]))
        // Draw right arrow view
        rightArrowRect = CGRect(x: frame.width * chart.state.top - Constants.arrowWidth,
                                    y: frame.height - Constants.navigationViewHeight - Constants.arrowLineWidth,
                                    width: Constants.arrowWidth,
                                    height: Constants.navigationViewHeight + (Constants.arrowLineWidth * 2))
        navigationViewRestLayers.append(add(roundedRect: rightArrowRect, color: arrowColor, by: [.bottomRight, .topRight]))
        // Draw bottom arrow view
        let arrowViewWidth = rightArrowRect.minX - (leftArrowRect.minX + leftArrowRect.width)
        let bottomArrowRect = CGRect(x: frame.width * chart.state.bottom + Constants.arrowWidth,
                                     y: frame.height - Constants.navigationViewHeight - Constants.arrowLineWidth,
                                     width: arrowViewWidth,
                                     height: Constants.arrowLineWidth)
        navigationViewRestLayers.append(add(rect: bottomArrowRect, color: arrowColor))
        // Draw top arrow view
        let topArrowRect = CGRect(x: frame.width * chart.state.bottom + Constants.arrowWidth,
                                  y: frame.height,
                                  width: arrowViewWidth,
                                  height: Constants.arrowLineWidth)
        navigationViewRestLayers.append(add(rect: topArrowRect, color: arrowColor))
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
        navigationViewRestLayers.append(leftArrowLayer)
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
        navigationViewRestLayers.append(rightArrowLayer)
    }
    
    // MARK: - Extra Functions -
    
    func addPanGR() {
        panGR = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGR.delegate = self
        addGestureRecognizer(panGR)
    }
    
    @objc func handlePan(_ gr: UIPanGestureRecognizer) {
        let location = gr.location(in: self)
        let navigationViewScrollableRect = CGRect(x: leftArrowRect.minX + leftArrowRect.width + (Constants.arrowTouchExtraWidth / 2),
                                                  y: leftArrowRect.minY,
                                                  width: (rightArrowRect.minX - (Constants.arrowTouchExtraWidth / 2)) - (leftArrowRect.minX + leftArrowRect.width + (Constants.arrowTouchExtraWidth / 2)),
                                                  height: leftArrowRect.height)
        if gr.state == .began {
            if (leftArrowRect.insetBy(dx: -Constants.arrowTouchExtraWidth, dy: 0).contains(location)) {
                pannedView = .leftArrow
            } else if (rightArrowRect.insetBy(dx: -Constants.arrowTouchExtraWidth, dy: 0).contains(location)) {
                pannedView = .rightArrow
            } else if (navigationViewScrollableRect.contains(location)) {
                pannedView = .navigationView
            } else if (scrollRect.contains(location)) {
                pannedView = .chartView
            }
            pannedState = ChartState(chart.state.bottom, chart.state.top)
        }
        if gr.state == .began || gr.state == .changed {
            let translation = gr.translation(in: self)
            var relativeTranslation = translation.x / frame.width
            if (pannedView == .leftArrow) {
                if pannedState.bottom + relativeTranslation < 0 {
                    relativeTranslation = 0 - pannedState.bottom
                } else if pannedState.bottom + relativeTranslation > pannedState.top - Constants.minDiffInBottomAndTop {
                    relativeTranslation = pannedState.top - Constants.minDiffInBottomAndTop - pannedState.bottom
                }
                chart.state.bottom = pannedState.bottom + relativeTranslation
                updateData()
            } else if (pannedView == .rightArrow) {
                if pannedState.top + relativeTranslation > 1 {
                    relativeTranslation = 1 - pannedState.top
                } else if pannedState.top + relativeTranslation < pannedState.bottom + Constants.minDiffInBottomAndTop {
                    relativeTranslation = pannedState.bottom + Constants.minDiffInBottomAndTop - pannedState.top
                }
                chart.state.top = pannedState.top + relativeTranslation
                updateData()
            } else if (pannedView == .navigationView) {
                if pannedState.bottom + relativeTranslation < 0 {
                    relativeTranslation = 0 - pannedState.bottom
                } else if pannedState.top + relativeTranslation > 1 {
                    relativeTranslation = 1 - pannedState.top
                }
                chart.state.bottom = pannedState.bottom + relativeTranslation
                chart.state.top = pannedState.top + relativeTranslation
                updateData()
            } else if (pannedView == .chartView) {
                relativeTranslation = translation.x / chartWidth
                if pannedState.bottom - relativeTranslation < 0 {
                    relativeTranslation = pannedState.bottom
                } else if pannedState.top - relativeTranslation > 1 {
                    relativeTranslation = -1 * (1 - pannedState.top)
                }
                chart.state.bottom = pannedState.bottom - relativeTranslation
                chart.state.top = pannedState.top - relativeTranslation
                updateData()
            }
        } else {
            pannedView = nil
        }
    }
}

extension ChartView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return pannedView == nil
    }
}
