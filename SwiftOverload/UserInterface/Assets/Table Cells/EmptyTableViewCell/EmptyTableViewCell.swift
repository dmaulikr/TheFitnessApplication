//
//  EmptyTableViewCell.swift
//  SwiftOverload
//
//  Created by Milan de Ruiter on 03-07-17.
//  Copyright © 2017 Milan de Ruiter. All rights reserved.
//

import UIKit

class EmptyTableViewCell: UITableViewCell {

    @IBOutlet weak var cellLabel: UILabel!
    
    func render(for string:String) {
        self.selectionStyle = .none
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        
        
        cellLabel.text = string
        cellLabel.font = UIFont(name: "HelveticaNeue-thin", size: 16)
        cellLabel.alpha = 1
        cellLabel.textColor = UIColor.black
        
    }
    
}
