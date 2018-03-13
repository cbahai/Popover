//
//  ViewController.swift
//  PopoverDemo
//
//  Created by Chai on 2018/3/8.
//  Copyright © 2018年 FYH. All rights reserved.
//

import UIKit
import Popover

class ViewController: UIViewController {
    
    var pvc22: PopoverViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func pvc() -> PopoverViewController {
        let pvc = PopoverViewController()
        pvc.popoverView.layer.shadowColor = UIColor.black.cgColor
        pvc.popoverView.layer.shadowOffset = CGSize(width: 2, height: 2)
        pvc.popoverView.layer.shadowOpacity = 0.3
        pvc.popoverView.layer.shadowRadius = 2
        pvc.borderWidth = 1
        pvc.cornerRadius = 3
        pvc.maskColor = UIColor(white: 0, alpha: 0.2)
        pvc.callback = { (vc, isShow) in
            print(isShow)
        }
        return pvc
    }

    @IBAction func btnClick(_ sender: UIButton, forEvent event: UIEvent) {
        var pvc = self.pvc()
        pvc.trigger = sender
        switch sender.tag {
        case 1:
            pvc.content = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 150))
            pvc.arrowDirection = .up
            pvc.fillColor = UIColor.blue
        case 2:
            let content = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "B")
            content.view.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
            pvc.content = content
            pvc.arrowDirection = .down
        case 3:
            pvc.content = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 200))
            pvc.arrowDirection = .left
            pvc.arrowSize = CGSize(width: 7, height: 13)
            pvc.fillColor = UIColor.green
        case 4:
            pvc.content = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
            pvc.arrowDirection = .right
            pvc.arrowSize = CGSize(width: 7, height: 13)
            pvc.fillColor = UIColor.brown
        case 22:
            if self.pvc22 == nil {
                let content = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "B")
                content.view.frame = CGRect(x: 0, y: 0, width: 300, height: 350)
                pvc.content = content
                pvc.arrowDirection = .down
                self.pvc22 = pvc
            } else {
                pvc = self.pvc22!
            }
        default:
            break
        }
        pvc.show(in: self)
    }
    
    @IBAction func leftBarButtonItemClick(_ sender: UIBarButtonItem, forEvent event: UIEvent) {
        let pvc = self.pvc()
        pvc.trigger = event
        pvc.content = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 150))
        pvc.arrowDirection = .up
        pvc.fillColor = UIColor.red
        pvc.offset = CGPoint(x: 0, y: -5)
        pvc.show(in: self)
    }
    
    @IBAction func rightBarButtonItemClick(_ sender: UIBarButtonItem, forEvent event: UIEvent) {
        let pvc = self.pvc()
        pvc.trigger = event
        pvc.content = UIView(frame: CGRect(x: 0, y: 0, width: 250, height: 300))
        pvc.arrowDirection = .right
        pvc.arrowSize = CGSize(width: 10, height: 20)
        pvc.fillColor = UIColor.purple
        pvc.show(in: self)
    }
}
