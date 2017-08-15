//
//  NavigationButton.swift
//  SwiftOverload
//
//  Created by Milan de Ruiter on 03-07-17.
//  Copyright © 2017 Milan de Ruiter. All rights reserved.
//

import UIKit

class NavigationButton: UIButton {
    
    // MARK: Initializers
    
    init(frame:CGRect, title:String, position:UIControlContentHorizontalAlignment) {
        super.init(frame: frame)
        self.setTitle(title, for: .normal)
    }
    
    init(frame:CGRect, image:String, position:UIControlContentHorizontalAlignment) {
        super.init(frame: frame)
        
        self.contentHorizontalAlignment = position
        self.frame = frame
        self.setImage(UIImage(named: image), for: .normal)
        
    }
    
    convenience init(title:String, position:UIControlContentHorizontalAlignment) {
        let frame:CGRect = CGRect(x: 0, y: 0, width: 44, height: 50)
        self.init(frame: frame, title: title, position: position)
    }
    
    convenience init(image:String, position:UIControlContentHorizontalAlignment) {
        let frame:CGRect = CGRect(x: 0, y: 0, width: 44, height: 50)
        self.init(frame: frame, image: image, position: position)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Helpers
    
    
}
