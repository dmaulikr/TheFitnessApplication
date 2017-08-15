//
//  AddTableViewCell.swift
//  SwiftOverload
//
//  Created by Milan de Ruiter on 05-07-17.
//  Copyright © 2017 Milan de Ruiter. All rights reserved.
//

import UIKit

class AddTableViewCell: UITableViewCell {
    
    @IBOutlet weak var reputitionTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    
    func render(for indexPath:IndexPath) {
        self.selectionStyle = .none
        
        weightTextField.borderStyle = .none
        weightTextField.keyboardType = .numberPad
        weightTextField.tag = 1
        
        reputitionTextField.borderStyle = .none
        reputitionTextField.keyboardType = .numberPad
        reputitionTextField.tag = 2
    }
    
}
