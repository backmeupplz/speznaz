//
//  UIView+Add.swift
//  SpeznazDemo
//
//  Created by Nikita Kolmogorov on 2019-03-22.
//  Copyright © 2019 Nikita Kolmogorov. All rights reserved.
//

import UIKit

extension UIView {
    func addLine(from: CGPoint, to: CGPoint, color: UIColor, layer: CALayer? = nil) -> CAShapeLayer {
        let path = UIBezierPath()
        path.move(to: from)
        path.addLine(to: to)
        
        let lineLayer = CAShapeLayer()
        lineLayer.path = path.cgPath
        lineLayer.lineWidth = 1
        lineLayer.strokeColor = color.cgColor
        (layer ?? self.layer).addSublayer(lineLayer)
        return lineLayer
    }
    
    func addLabel(text: String, at: CGPoint, color: UIColor, layer: CALayer? = nil, width: CGFloat? = nil) -> CATextLayer {
        let textLayer = CATextLayer()
        textLayer.frame = CGRect(x: at.x, y: at.y, width: width ?? 400, height: Constants.labelHeight)
        textLayer.string = text
        textLayer.foregroundColor = color.cgColor
        textLayer.alignmentMode = .left
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.font = Constants.font
        textLayer.fontSize = 12.0
        (layer ?? self.layer).addSublayer(textLayer)
        return textLayer
    }
    
    func add(rect: CGRect, color: UIColor) -> CAShapeLayer {
        let rectLayer = CAShapeLayer()
        rectLayer.path = UIBezierPath(rect: rect).cgPath
        rectLayer.fillColor = color.cgColor
        layer.addSublayer(rectLayer)
        return rectLayer
    }
    
    func add(roundedRect: CGRect, color: UIColor, by roundedCorners: UIRectCorner, cornerRadius: CGFloat = 2, layer: CALayer? = nil) -> CAShapeLayer {
        let rectLayer = CAShapeLayer()
        rectLayer.path = UIBezierPath(roundedRect: roundedRect, byRoundingCorners: roundedCorners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
        rectLayer.fillColor = color.cgColor
        (layer ?? self.layer).addSublayer(rectLayer)
        return rectLayer
    }
    
    func add(circle: CGRect, fillColor: UIColor, backgroundColor: UIColor, layer: CALayer? = nil) -> CAShapeLayer {
        let circleLayer = CAShapeLayer()
        circleLayer.path = UIBezierPath(ovalIn: circle.offsetBy(dx: circle.width / -2, dy: 0)).cgPath
        circleLayer.fillColor = backgroundColor.cgColor
        circleLayer.strokeColor = fillColor.cgColor
        circleLayer.lineWidth = 2
        (layer ?? self.layer).addSublayer(circleLayer)
        return circleLayer
    }
}
