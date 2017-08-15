//
//  DetailTableViewCell.swift
//  SwiftOverload
//
//  Created by Milan de Ruiter on 05-07-17.
//  Copyright © 2017 Milan de Ruiter. All rights reserved.
//

import UIKit

class DetailTableViewCell: UITableViewCell {

    @IBOutlet weak var detailLabel: UILabel!
    
    func render(for text:String, highlighted str:String? = "") {
        self.selectionStyle = .none
        
        detailLabel.font = UIFont(name: "HelveticaNeue-thin", size: 16)
        detailLabel.alpha = 1
        detailLabel.numberOfLines = 2
        detailLabel.text = text
        
    }
    
    
}
