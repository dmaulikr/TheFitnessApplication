//
//  Loader.swift
//  SwiftOverload
//
//  Created by Milan de Ruiter on 11-07-17.
//  Copyright © 2017 Milan de Ruiter. All rights reserved.
//

import UIKit

class LoaderView:UIView {
    
    // MARK: Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(view:UIView) {
        super.init(frame: view.frame)
        create(for: view, count: 10, width: 5, minHeight: 5, maxHeight: 15, padding: 8)
    }
    
    // MARK: Create
    
    func create(for loader:UIView, count:Int, width:Int, minHeight:Int, maxHeight:Int, padding:Int) {
        let container:UIView = UIView()
        container.frame = CGRect(x: 0, y: 0, width: count * (width + padding), height: maxHeight )
        container.center = loader.center
        loader.addSubview(container)
        
        for i in 0 ..< count {
            let loadingBar:UIView = UIView()
            loadingBar.frame = CGRect(x: i * (width + padding), y: maxHeight / 2, width: width, height: minHeight)
            loadingBar.backgroundColor = UIColor.lightGray
            container.addSubview(loadingBar)
            
            let duration = TimeInterval(Utils.getRandom(max: 4, min: 2))
            self.animate(loadingBar, duration: duration, min: Float(minHeight), max:Float(maxHeight) )
        }
    }
    
    // MARK: Animate
    
    func animate(_ view:UIView, duration:TimeInterval, min:Float, max:Float) {
        var animations:[Float] = []
        
        let animationGroup:CAAnimationGroup = CAAnimationGroup()
        animationGroup.duration = duration
        animationGroup.repeatCount = Float.infinity
        animationGroup.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
        
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale.y")
        scaleAnimation.duration = duration
        
        scaleAnimation.keyTimes = [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1]
        for _ in 0 ..< scaleAnimation.keyTimes!.count {
            animations.append(Utils.getRandom(max: max, min: min))
        }
        scaleAnimation.values = animations
        animationGroup.animations = [scaleAnimation]
        view.layer.add(animationGroup, forKey: "loader")
    }
    
}
