//
//  PopoverViewController.swift
//  Popover
//
//  Created by Chai on 2018/3/8.
//  Copyright © 2018年 FYH. All rights reserved.
//

import UIKit

public protocol PopoverContent {}
extension UIView: PopoverContent {}
extension UIViewController: PopoverContent {}

public protocol PopoverTrigger {}
extension UIView: PopoverTrigger {}
extension UIEvent: PopoverTrigger {}

public class PopoverViewController: UIViewController {
    
    /// 内容(必须)
    public var content: PopoverContent!
    /// 触发点(必须)
    public var trigger: PopoverTrigger!
    /// 箭头方向
    public var arrowDirection: UIImage.ArrowDirection = .up
    /// 箭头大小
    public var arrowSize: CGSize = CGSize(width: 13, height: 7)
    /// 填充颜色
    public var fillColor: UIColor = UIColor.white
    /// 边线颜色
    public var borderColor: UIColor = UIColor(white: 0.8, alpha: 1)
    /// 边线宽
    public var borderWidth: CGFloat = 0
    /// 角半径
    public var cornerRadius: CGFloat = 0
    /// 屏幕边缘距离
    public var sideEdge: CGFloat = 10
    /// 偏移量
    public var offset: CGPoint = CGPoint.zero
    /// 蒙板颜色
    public var maskColor: UIColor = UIColor(white: 0, alpha: 0)
    /// 是否安全区显示
    public var isSafeAreaDisplay: Bool = true
    /// 显示及消失回调
    public var callback: ((PopoverViewController, Bool/*显示(true);消失(false)*/) -> Void)?
    /// 显示动画
    public var showAnimation: CAKeyframeAnimation = {
        let animation = CAKeyframeAnimation(keyPath: "transform")
        animation.duration = 0.15
        animation.values = [
            NSValue(caTransform3D: CATransform3DMakeScale(0.5, 0.5, 1.0)),
            NSValue(caTransform3D: CATransform3DMakeScale(1.0, 1.0, 1.0))
        ]
        return animation
    }()
    /// 消失动画
    public var dismissAnimation: CAKeyframeAnimation = {
        let animation = CAKeyframeAnimation(keyPath: "transform")
        animation.duration = 0.15
        animation.values = [
            NSValue(caTransform3D: CATransform3DMakeScale(1.0, 1.0, 1.0)),
            NSValue(caTransform3D: CATransform3DMakeScale(0.5, 0.5, 1.0))
        ]
        return animation
    }()
    
    public let popoverView = UIView()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(white: 0, alpha: 0)
        
        let maskButton = UIButton(frame: self.view.bounds)
        maskButton.addTarget(self, action: #selector(maskButtonClick), for: .touchUpInside)
        self.view.addSubview(maskButton)
        
        self.view.addSubview(popoverView)
        setupPopover()
    }
    
    deinit {
        if let content = self.content as? UIViewController {
            content.willMove(toParentViewController: nil)
            content.view.removeFromSuperview()
            content.removeFromParentViewController()
        }
    }

    public func show(in viewController: UIViewController) {
        popoverView.alpha = 1
        popoverView.isHidden = true
        
        modalPresentationStyle = .overFullScreen
        viewController.present(self, animated: false) { [weak self] in
            guard let this = self else { return }
            this.popoverView.isHidden = false
            this.popoverView.layer.add(this.showAnimation, forKey: nil)
            UIView.animate(withDuration: this.showAnimation.duration) { [weak this] in
                this?.view.backgroundColor = this?.maskColor
            }
        }
        callback?(self, true)
    }
    
    public func dismiss() {
        popoverView.layer.add(dismissAnimation, forKey: nil)
        UIView.animate(withDuration: dismissAnimation.duration, animations: { [weak self] in
            self?.view.backgroundColor = UIColor(white: 0, alpha: 0)
            self?.popoverView.alpha = 0
        }, completion: { [weak self] (finished) in
            guard let this = self else { return }
            if finished {
                this.dismiss(animated: false)
                this.callback?(this, false)
            }
        })
    }
    
    func setupPopover() {
        // 触发点的视图中心位置及大小
        var triggerCenter = CGPoint.zero
        var triggerSize = CGSize.zero
        if let trigger = self.trigger as? UIView, let triggerSuperview = trigger.superview {
            triggerCenter = triggerSuperview.convert(trigger.center, to: self.view)
            triggerSize = trigger.frame.size
        } else if let trigger = self.trigger as? UIEvent, let triggerView = trigger.allTouches?.first?.view, let triggerViewSuperView = triggerView.superview {
            triggerCenter = triggerViewSuperView.convert(triggerView.center, to: self.view)
            triggerSize = triggerView.frame.size
        }
        
        // 箭头图片
        let arrowImage = UIImage.imageOfArrow(direction: arrowDirection, size: arrowSize, fillColor: fillColor, borderColor: borderColor, borderWidth: borderWidth)
        let arrowImageView = UIImageView(image: arrowImage)

        // 内容视图
        var contentView: UIView!
        if let content = self.content as? UIView {
            contentView = content
        } else if let content = self.content as? UIViewController {
            contentView = content.view
        }
        contentView.backgroundColor = fillColor
        contentView.layer.borderWidth = borderWidth
        contentView.layer.borderColor = borderColor.cgColor
        contentView.layer.cornerRadius = cornerRadius
        contentView.layer.masksToBounds = true

        // 调整各视图位置
        switch arrowDirection {
        case .up:
            // popoverView位置
            popoverView.frame = CGRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.height + arrowImageView.frame.height - borderWidth)
            var popoverViewFrame = popoverView.frame
            popoverViewFrame.origin.x = triggerCenter.x - popoverView.frame.width / 2
            popoverViewFrame.origin.y = triggerCenter.y + triggerSize.height / 2
            popoverView.frame = adjustSideEdge(sourceFrame: popoverViewFrame)
            
            let contentViewOffset = popoverView.frame.origin.x - popoverViewFrame.origin.x
            
            // 箭头位置
            var arrowImageViewFrame = arrowImageView.frame
            arrowImageViewFrame.origin.x = (popoverView.frame.width - arrowImageView.frame.width) / 2 - contentViewOffset
            arrowImageView.frame = arrowImageViewFrame
            
            // 内容视图位置
            var contentViewFrame = contentView.frame
            contentViewFrame.origin.x = 0
            contentViewFrame.origin.y = arrowImageView.frame.origin.y + arrowImageView.frame.size.height - borderWidth
            contentView.frame = contentViewFrame
            
            // 调整锚点及对应位置
            popoverView.modifyAnchor(to: .top, offset: contentViewOffset)
        case .down:
            popoverView.frame = CGRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.height + arrowImageView.frame.height - borderWidth)
            var popoverViewFrame = popoverView.frame
            popoverViewFrame.origin.x = triggerCenter.x - popoverView.frame.width / 2
            popoverViewFrame.origin.y = triggerCenter.y - triggerSize.height / 2 - popoverView.frame.height
            popoverView.frame = adjustSideEdge(sourceFrame: popoverViewFrame)
            
            let contentViewOffset = popoverView.frame.origin.x - popoverViewFrame.origin.x
            
            var arrowImageViewFrame = arrowImageView.frame
            arrowImageViewFrame.origin.x = (popoverView.frame.width - arrowImageView.frame.width) / 2 - contentViewOffset
            arrowImageViewFrame.origin.y = popoverView.frame.height - arrowImageView.frame.height
            arrowImageView.frame = arrowImageViewFrame
            
            var contentViewFrame = contentView.frame
            contentViewFrame.origin.x = 0
            contentViewFrame.origin.y = 0
            contentView.frame = contentViewFrame
            
            popoverView.modifyAnchor(to: .bottom, offset: contentViewOffset)
        case .left:
            popoverView.frame = CGRect(x: 0, y: 0, width: contentView.frame.width + arrowImageView.frame.width - borderWidth, height: contentView.frame.height)
            var popoverViewFrame = popoverView.frame
            popoverViewFrame.origin.x = triggerCenter.x + triggerSize.width / 2
            popoverViewFrame.origin.y = triggerCenter.y - popoverView.frame.height / 2
            popoverView.frame = adjustSideEdge(sourceFrame: popoverViewFrame)
            
            let contentViewOffset = popoverView.frame.origin.y - popoverViewFrame.origin.y
            
            var arrowImageViewFrame = arrowImageView.frame
            arrowImageViewFrame.origin.y = (contentView.frame.height - arrowImageView.frame.height) / 2 - contentViewOffset
            arrowImageView.frame = arrowImageViewFrame
            
            var contentViewFrame = contentView.frame
            contentViewFrame.origin.x = arrowImageView.frame.origin.x + arrowImageView.frame.width - borderWidth
            contentViewFrame.origin.y = 0
            contentView.frame = contentViewFrame
            
            popoverView.modifyAnchor(to: .left, offset: contentViewOffset)
        case .right:
            popoverView.frame = CGRect(x: 0, y: 0, width: contentView.frame.width + arrowImageView.frame.width - borderWidth, height: contentView.frame.height)
            var popoverViewFrame = popoverView.frame
            popoverViewFrame.origin.x = triggerCenter.x - triggerSize.width / 2 - popoverView.frame.width
            popoverViewFrame.origin.y = triggerCenter.y - popoverView.frame.height / 2
            popoverView.frame = adjustSideEdge(sourceFrame: popoverViewFrame)
            
            let contentViewOffset = popoverView.frame.origin.y - popoverViewFrame.origin.y
            
            var arrowImageViewFrame = arrowImageView.frame
            arrowImageViewFrame.origin.x = popoverView.frame.width - arrowImageView.frame.width
            arrowImageViewFrame.origin.y = (popoverView.frame.height - arrowImageView.frame.height) / 2 - contentViewOffset
            arrowImageView.frame = arrowImageViewFrame
            
            var contentViewFrame = contentView.frame
            contentViewFrame.origin.x = 0
            contentViewFrame.origin.y = 0
            contentView.frame = contentViewFrame
            
            popoverView.modifyAnchor(to: .right, offset: contentViewOffset)
        }
        
        // 偏移量设置
        var popoverViewFrame = popoverView.frame
        popoverViewFrame.origin = CGPoint(x: popoverViewFrame.origin.x + offset.x, y: popoverViewFrame.origin.y + offset.y)
        popoverView.frame = popoverViewFrame
        
        // 添加视图
        if let content = self.content as? UIView {
            popoverView.addSubview(content)
        } else if let content = self.content as? UIViewController {
            addChildViewController(content)
            popoverView.addSubview(content.view)
            content.didMove(toParentViewController: self)
        }
        popoverView.addSubview(arrowImageView)
    }
    
    /// 调整屏幕边缘距离
    func adjustSideEdge(sourceFrame: CGRect) -> CGRect {
        var safeAreaInsets = UIEdgeInsets.zero
        if #available(iOS 11.0, *), isSafeAreaDisplay, let keyWindow = UIApplication.shared.keyWindow {
            safeAreaInsets = keyWindow.safeAreaInsets
        }
        
        var frame = sourceFrame
        switch arrowDirection {
        case .up, .down:
            if frame.origin.x < sideEdge {
                frame.origin.x = sideEdge + safeAreaInsets.left
            } else if frame.origin.x + frame.width + sideEdge > self.view.frame.width {
                frame.origin.x = self.view.frame.width - sideEdge - frame.width - safeAreaInsets.right
            }
        case .left, .right:
            if frame.origin.y < sideEdge {
                frame.origin.y = sideEdge + safeAreaInsets.top
            } else if frame.origin.y + frame.height + sideEdge > self.view.frame.height {
                frame.origin.y = self.view.frame.height - sideEdge - frame.height - safeAreaInsets.bottom
            }
        }
        return frame
    }
    
    @objc func maskButtonClick() {
        dismiss()
    }
}
