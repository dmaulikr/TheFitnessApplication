//
//  ButtonTableViewCell.swift
//  SwiftOverload
//
//  Created by Milan de Ruiter on 17-07-17.
//  Copyright © 2017 Milan de Ruiter. All rights reserved.
//

import UIKit

class ButtonTableViewCell: UITableViewCell {

    @IBOutlet weak var cellButton: UIButton!
    
    func render(for title:String) {
        
        cellButton.setTitle(title, for: .normal)
        cellButton.tintColor = .white
        cellButton.backgroundColor = UIColor.customDarkGray
        cellButton.layer.cornerRadius = 5
        cellButton.contentEdgeInsets = UIEdgeInsetsMake(10, 12, 10, 12)
        
        self.backgroundColor = .clear
        self.layer.backgroundColor = UIColor.clear.cgColor
        
    }
    
}
