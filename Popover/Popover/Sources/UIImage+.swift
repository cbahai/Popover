//
//  UIImage+.swift
//  Popover
//
//  Created by Chai on 2018/3/8.
//  Copyright © 2018年 FYH. All rights reserved.
//

import UIKit

extension UIImage {
    
    /// 箭头方向
    public enum ArrowDirection {
        case up
        case down
        case left
        case right
    }
    
    /// 绘制箭头图片
    static func imageOfArrow(direction: ArrowDirection, size: CGSize, fillColor: UIColor, borderColor: UIColor, borderWidth: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        
        if let context = UIGraphicsGetCurrentContext() {
            context.setStrokeColor(borderColor.cgColor)
            context.setFillColor(fillColor.cgColor)
            context.setLineWidth(borderWidth)
            
            switch direction {
            case .up:
                context.move(to: CGPoint(x: 0, y: size.height))
                context.addLine(to: CGPoint(x: size.width / 2, y: 0))
                context.addLine(to: CGPoint(x: size.width, y: size.height))
            case .down:
                context.move(to: CGPoint(x: 0, y: 0))
                context.addLine(to: CGPoint(x: size.width / 2, y: size.height))
                context.addLine(to: CGPoint(x: size.width, y: 0))
            case .left:
                context.move(to: CGPoint(x: size.width, y: 0))
                context.addLine(to: CGPoint(x: 0, y: size.height / 2))
                context.addLine(to: CGPoint(x: size.width, y: size.height))
            case .right:
                context.move(to: CGPoint(x: 0, y: 0))
                context.addLine(to: CGPoint(x: size.width, y: size.height / 2))
                context.addLine(to: CGPoint(x: 0, y: size.height))
            }
            
            context.drawPath(using: .fillStroke)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image ?? UIImage()
    }
}
