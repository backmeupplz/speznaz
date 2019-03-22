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
    
    var oldMaxMinY = MaxMin(0, 0)
    var maxMinY = MaxMin(0, 0)
    var maxMinX = MaxMin(0, 0)
    var yWentUp = true
    var yChanged = false
    
    var panGR: UIPanGestureRecognizer!
    
    var pannedView: PannedView?
    var pannedState: ChartState!
    
    var leftArrowRect: CGRect!
    var rightArrowRect: CGRect!
    
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
        // Save value for later
        oldMaxMinY = maxMinY
        // Setup Y
        maxMinY = MaxMin(CGFloat(tempTopValue), CGFloat(tempBottomValue))
        // Setup X
        maxMinX = MaxMin(CGFloat(chart.columns["x"]!.values.last!),
                         CGFloat(chart.columns["x"]!.values.first!))
        // Calculate if y went up
        yWentUp = oldMaxMinY.diff > maxMinY.diff
        yChanged = oldMaxMinY.diff != maxMinY.diff
        // Calculate dimensions
        chartHeight = frame.height - Constants.navigationViewHeight - Constants.labelHeight
        segmentHeight = (chartHeight - Constants.labelHeight) / 5.0
    }
    
    // MARK: - Rendering -
    
    func render(animated: Bool) {
        drawGrid(animated: animated)
        drawCharts(animated: animated)
        drawGridTitles(animated: animated)
//        drawNavigationViewCharts(animated: animated)
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
            let minimal = chartHeight * maxMinY.diff + maxMinY.min
            let current = floor(chartHeight - (y + Constants.labelHeight))
            let flooredResult = floor(current / minimal)
            let roundedResult = Int(flooredResult)
            let text = "\(roundedResult)"
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
        // Draw charts
        var elevatedBottomYValue = maxMinY.min - (maxMinY.diff / 10.0)
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
                let translatedX = ((x - maxMinX.min) / maxMinX.diff) * frame.width
                let y = CGFloat(yValues[i])
                let translatedY = chartHeight - (((y - elevatedBottomYValue) / (maxMinY.max - elevatedBottomYValue)) * chartHeight)
                let coordinate = CGPoint(x: translatedX, y: translatedY)
                if (i == 0) {
                    path.move(to: coordinate)
                } else {
                    path.addLine(to: coordinate)
                }
            }
            let oldPath = UIBezierPath()
            if !wasSelected {
                var oldElevatedBottomYValue = oldMaxMinY.min - (oldMaxMinY.diff / 10.0)
                if (oldElevatedBottomYValue < 0) {
                    oldElevatedBottomYValue = 0.0
                }
                for i in 0 ..< yValues.count {
                    let x = CGFloat(xValues[i])
                    let translatedX = ((x - maxMinX.min) / maxMinX.diff) * frame.width
                    let y = CGFloat(yValues[i])
                    let translatedY = chartHeight - (((y - oldElevatedBottomYValue) / (oldMaxMinY.max - oldElevatedBottomYValue)) * chartHeight)
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
                chartLayer.add(animation, forKey: "animatePath")
            } else if animated && !wasSelected && column.selected {
                chartLayer.opacity = 0
                chartLayer.path = oldPath.cgPath
                chartLayer.fade(fadeIn: true, removeOnCompletion: false)
                let animation = CABasicAnimation(keyPath: "path")
                animation.fromValue = chartLayer.path
                animation.toValue = path.cgPath
                animation.duration = AnimationConstants.animationDuration
                chartLayer.add(animation, forKey: "animatePath")
            } else if animated && wasSelected && !column.selected {
                chartLayer.opacity = 1
                chartLayer.path = oldPath.cgPath
                chartLayer.fade(fadeIn: false, removeOnCompletion: true)
                let animation = CABasicAnimation(keyPath: "path")
                animation.fromValue = chartLayer.path
                animation.toValue = path.cgPath
                animation.duration = AnimationConstants.animationDuration
                chartLayer.add(animation, forKey: "animatePath")
            }
            chartLayer.path = path.cgPath
            chartLayer.strokeColor = color
            chartLayer.fillColor = UIColor.clear.cgColor
            chartLayer.lineWidth = Constants.chartLineWidth
            chartLayer.lineCap = .round
            if column.selected {
                layer.addSublayer(chartLayer)
            } else if !animated {
                chartLayer.removeFromSuperlayer()
            }
            chartLayers[columnName] = chartLayer
        }
    }
    
    func drawNavigationViewCharts(animated: Bool) {
        // Remove unselected charts
        for columnName in navigationViewChartLayers.keys {
            if let column = chart.columns[columnName], !column.selected {
                navigationViewChartLayers[columnName]?.removeFromSuperlayer()
                navigationViewChartLayers[columnName] = nil
            }
        }
        for columnName in chart.columnNames {
            guard let column = chart.columns[columnName], column.selected else {
                continue
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
                let translatedY = frame.height - Constants.chartLineWidth - (((y - maxMinY.min) / maxMinY.diff) * (Constants.navigationViewHeight - (Constants.chartLineWidth * 2)))
                let coordinate = CGPoint(x: translatedX, y: translatedY)
                if (i == 0) {
                    path.move(to: coordinate)
                } else {
                    path.addLine(to: coordinate)
                }
            }
            // Draw line
            let exists = navigationViewChartLayers[columnName] != nil
            let chartLayer = navigationViewChartLayers[columnName] ?? CAShapeLayer()
            if exists && animated {
                let animation = CABasicAnimation(keyPath: "path")
                animation.fromValue = chartLayer.path
                animation.toValue = path.cgPath
                animation.duration = 0.1
                chartLayer.add(animation, forKey: "animatePath")
            }
            chartLayer.path = path.cgPath
            chartLayer.strokeColor = color
            chartLayer.fillColor = UIColor.clear.cgColor
            chartLayer.lineWidth = Constants.chartLineWidth
            chartLayer.lineCap = .round
            layer.addSublayer(chartLayer)
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
