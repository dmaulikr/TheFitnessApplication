//
//  GraphTableViewCell.swift
//  SwiftOverload
//
//  Created by Milan de Ruiter on 21-07-17.
//  Copyright © 2017 Milan de Ruiter. All rights reserved.
//

import UIKit

class GraphTableViewCell: UITableViewCell {
    
    // MARK: Outlets
    
    @IBOutlet weak var graph: Graph!
    
    func render() {
        
        self.backgroundColor = UIColor.customDarkGray
        
    }
    
}
