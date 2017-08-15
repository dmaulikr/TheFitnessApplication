//
//  Tabbar.swift
//  SwiftOverload
//
//  Created by Milan de Ruiter on 09-08-17.
//  Copyright © 2017 Milan de Ruiter. All rights reserved.
//

import UIKit

class Tabbar: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBar.items?.forEach({ (tabbarItem) in
            let inset:UIEdgeInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
            tabbarItem.imageInsets = inset
//            tabbarItem.image?.withRenderingMode(.alwaysTemplate)
        })
        
        self.tabBar.backgroundColor = UIColor.customDarkGray
        self.tabBar.barTintColor = UIColor.customDarkGray
        self.tabBar.tintColor = UIColor.white
        
    }
    
}
