//
//  Loader.swift
//  SwiftOverload
//
//  Created by Milan de Ruiter on 11-07-17.
//  Copyright © 2017 Milan de Ruiter. All rights reserved.
//

import UIKit

class Loader:UIView {
    
    // MARK: Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        let window = UIApplication.shared.keyWindow!
        super.init(frame: CGRect(x: 0, y: 0, width: 160, height: 160))
        
        self.center = window.center
        self.backgroundColor = UIColor.customDarkGray.withAlphaComponent(0.7)
        self.tag = 9
        self.layer.cornerRadius = 8
        
        let label:UILabel = createLabel()
        let indicator:UIActivityIndicatorView = createIndicator()
        indicator.center = CGPoint(x: self.frame.size.width / 2, y: (self.frame.size.height / 2 ) + 20)
        
        self.addSubview(label)
        self.addSubview(indicator)
        
        indicator.startAnimating()
    }
    
    // MARK: Create
    
    private func createLabel() -> UILabel {
        let label:UILabel = UILabel(frame: CGRect(
            x: 0,
            y: self.frame.size.height / 2 - 60,
            width: self.frame.size.width,
            height: 50
        ))
        
        label.text = "Loading"
        label.textColor = .white
        label.font = UIFont(name: "HelveticaNeue", size: 24)
        label.textAlignment = .center
        
        return label
    }
    
    private func createIndicator() -> UIActivityIndicatorView {
        let indicator:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        indicator.color = .white
        return indicator
        
    }
    
    
    
}

