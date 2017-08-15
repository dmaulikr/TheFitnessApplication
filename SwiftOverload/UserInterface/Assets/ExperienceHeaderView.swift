//
//  ExperienceHeaderView.swift
//  SwiftOverload
//
//  Created by Milan de Ruiter on 12-07-17.
//  Copyright © 2017 Milan de Ruiter. All rights reserved.
//

import UIKit

class ExperienceHeaderView: UIView {
    
    var experienceLabel:UILabel!
    var pointsLabel:UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createHeader()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createHeader()
    }
    
    func createHeader() {
        let window = UIApplication.shared.keyWindow!
        experienceLabel = UILabel()
        experienceLabel.frame = CGRect(x: 0, y: 10, width: window.frame.size.width, height: 35)
        experienceLabel.backgroundColor = .clear
        experienceLabel.textColor = .white
        experienceLabel.font = UIFont(name: "HelveticaNeue", size: 35)
        experienceLabel.textAlignment = .center
        experienceLabel.text = " "
        self.addSubview(experienceLabel)
        
        pointsLabel = UILabel()
        pointsLabel.frame = CGRect(x: 0, y: 50, width: window.frame.size.width, height: 25)
        pointsLabel.backgroundColor = .clear
        pointsLabel.textColor = .white
        pointsLabel.font = UIFont(name: "HelveticaNeue-thin", size: 10)
        pointsLabel.textAlignment = .center
        pointsLabel.text = " Points "
        self.addSubview(pointsLabel)
    }
    
}
