//
//  UIView+Add.swift
//  SpeznazDemo
//
//  Created by Nikita Kolmogorov on 2019-03-22.
//  Copyright © 2019 Nikita Kolmogorov. All rights reserved.
//

import UIKit

extension UIView {
    func addLine(from: CGPoint, to: CGPoint, color: UIColor) -> CAShapeLayer {
        let path = UIBezierPath()
        path.move(to: from)
        path.addLine(to: to)
        
        let lineLayer = CAShapeLayer()
        lineLayer.path = path.cgPath
        lineLayer.lineWidth = 1
        lineLayer.strokeColor = color.cgColor
        layer.addSublayer(lineLayer)
        return lineLayer
    }
    
    func addLabel(text: String, at: CGPoint, color: UIColor) -> CATextLayer {
        let textLayer = CATextLayer()
        textLayer.frame = CGRect(x: at.x, y: at.y, width: 400, height: Constants.labelHeight)
        textLayer.string = text
        textLayer.foregroundColor = color.cgColor
        textLayer.alignmentMode = .left
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.font = Constants.font
        textLayer.fontSize = 12.0
        layer.addSublayer(textLayer)
        return textLayer
    }
    
    func add(rect: CGRect, color: UIColor) -> CAShapeLayer {
        let rectLayer = CAShapeLayer()
        rectLayer.path = UIBezierPath(rect: rect).cgPath
        rectLayer.fillColor = color.cgColor
        layer.addSublayer(rectLayer)
        return rectLayer
    }
    
    func add(roundedRect: CGRect, color: UIColor, by roundedCorners: UIRectCorner, cornerRadius: CGFloat = 2) -> CAShapeLayer {
        let rectLayer = CAShapeLayer()
        rectLayer.path = UIBezierPath(roundedRect: roundedRect, byRoundingCorners: roundedCorners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
        rectLayer.fillColor = color.cgColor
        layer.addSublayer(rectLayer)
        return rectLayer
    }
}
