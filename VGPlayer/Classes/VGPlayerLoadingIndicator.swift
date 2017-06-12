//
//  VGPlayerLoadingIndicator.swift
//  VGPlayer
//
//  Created by Vein on 2017/6/5.
//  Copyright © 2017年 Vein. All rights reserved.
//

import UIKit

fileprivate let kRotationAnimationKey = "kRotationAnimationKey.rotation"

open class VGPlayerLoadingIndicator: UIView {
    
   fileprivate let indicatorLayer = CAShapeLayer()
    var timingFunction : CAMediaTimingFunction!
    var isAnimating = false

   public override init(frame : CGRect) {
        super.init(frame : frame)
        commonInit()
    }
    
   public convenience init() {
        self.init(frame:CGRect.zero)
        commonInit()
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        commonInit()
    }
    
    override open func layoutSubviews() {
        indicatorLayer.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height);
        updateIndicatorLayerPath()
    }
    
   internal func commonInit(){
        timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        setupIndicatorLayer()
    }
    
   internal func setupIndicatorLayer() {
        indicatorLayer.strokeColor = UIColor.white.cgColor
        indicatorLayer.fillColor = nil
        indicatorLayer.lineWidth = 2.0
        indicatorLayer.lineJoin = kCALineJoinRound;
        indicatorLayer.lineCap = kCALineCapRound;
        layer.addSublayer(indicatorLayer)
        updateIndicatorLayerPath()
    }
    
   internal func updateIndicatorLayerPath() {
        let center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        let radius = min(self.bounds.width / 2, self.bounds.height / 2) - indicatorLayer.lineWidth / 2
        let startAngle: CGFloat = 0
        let endAngle: CGFloat = 2 * CGFloat(Double.pi)
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        indicatorLayer.path = path.cgPath
        
        indicatorLayer.strokeStart = 0.1
        indicatorLayer.strokeEnd = 1.0
    }
    
    open var lineWidth: CGFloat {
        get {
            return indicatorLayer.lineWidth
        }
        set(newValue) {
            indicatorLayer.lineWidth = newValue
            updateIndicatorLayerPath()
        }
    }
    
   open var strokeColor: UIColor {
        get {
            return UIColor(cgColor: indicatorLayer.strokeColor!)
        }
        set(newValue) {
            indicatorLayer.strokeColor = newValue.cgColor
        }
    }
    
   open func startAnimating() {
        if self.isAnimating {
            return
        }
        
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.duration = 1
        animation.fromValue = 0
        animation.toValue = (2 * Double.pi)
        animation.repeatCount = Float.infinity
        animation.isRemovedOnCompletion = false
        indicatorLayer.add(animation, forKey: kRotationAnimationKey)
        isAnimating = true;
    }
    
   open func stopAnimating() {
        if !isAnimating {
            return
        }
        
        indicatorLayer.removeAnimation(forKey: kRotationAnimationKey)
        isAnimating = false;
    }
    
}
