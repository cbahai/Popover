//
//  UIView+.swift
//  Popover
//
//  Created by Chai on 2018/3/8.
//  Copyright © 2018年 FYH. All rights reserved.
//

import UIKit

extension UIView {
    
    /// 锚点位置
    enum AnchorLocation {
        case top
        case bottom
        case left
        case right
    }
    
    /// 修改锚点位置
    func modifyAnchor(to location: AnchorLocation, offset: CGFloat) {
        switch location {
        case .top:
            self.layer.anchorPoint = CGPoint(x: 0.5 - offset / self.frame.width, y: 0)
            var viewFrame = self.frame
            viewFrame.origin.x -= offset
            viewFrame.origin.y -= self.frame.height / 2
            self.frame = viewFrame
        case .bottom:
            self.layer.anchorPoint = CGPoint(x: 0.5 - offset / self.frame.width, y: 1)
            var viewFrame = self.frame
            viewFrame.origin.x -= offset
            viewFrame.origin.y += self.frame.height / 2
            self.frame = viewFrame
        case .left:
            self.layer.anchorPoint = CGPoint(x: 0, y: 0.5 - offset / self.frame.height)
            var viewFrame = self.frame
            viewFrame.origin.x -= self.frame.width / 2
            viewFrame.origin.y -= offset
            self.frame = viewFrame
        case .right:
            self.layer.anchorPoint = CGPoint(x: 1, y: 0.5 - offset / self.frame.height)
            var viewFrame = self.frame
            viewFrame.origin.x += self.frame.width / 2
            viewFrame.origin.y -= offset
            self.frame = viewFrame
        }
    }
}
