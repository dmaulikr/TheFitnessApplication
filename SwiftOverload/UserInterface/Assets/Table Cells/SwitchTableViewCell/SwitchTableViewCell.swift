//
//  SwitchTableViewCell.swift
//  SwiftOverload
//
//  Created by Milan de Ruiter on 21-07-17.
//  Copyright © 2017 Milan de Ruiter. All rights reserved.
//

import UIKit

class SwitchTableViewCell: UITableViewCell {
    
    // MARK: Outlets
    
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var cellSwitch: UISwitch!
    
    
    func render(for string:String, state:Bool) {
        self.selectionStyle = .none
        
        cellLabel.attributedText = nil
        cellLabel.text = string
        cellLabel.font = UIFont(name: "HelveticaNeue-thin", size: 18)!
        cellLabel.alpha = 1
        cellLabel.textColor = UIColor.black
        
        cellSwitch.setOn(state, animated: true)
        cellSwitch.onTintColor = UIColor.customDarkGray
    }
    
}
