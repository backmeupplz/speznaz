//
//  ChartView.swift
//  SpeznazDemo
//
//  Created by Nikita Kolmogorov on 2019-03-16.
//  Copyright © 2019 Nikita Kolmogorov. All rights reserved.
//

import UIKit

class ChartView: UIView {

    // MARK: - Properties -
    
    var chart: Chart!
    
    // MARK: - Public Functions -
    
    public func updateData() {
        self.setNeedsDisplay()
    }
    
    // MARK: - Rendering -
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        addRectangles(rect)
    }
    
    func addRectangles(_ rect: CGRect) {
        let elementWidth = rect.width / CGFloat(chart.columnNames.count)
        for i in 0 ..< chart.columns.values.count {
            let column = Array(chart.columns.values)[i]
            let drawRect = CGRect(x: CGFloat(i) * elementWidth, y: 0, width: elementWidth, height: rect.height)
            let path = UIBezierPath(ovalIn: drawRect)
            chart.colors[column.name]?.set()
            
            path.fill()
        }
    }
}
