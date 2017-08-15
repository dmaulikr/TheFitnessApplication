//
//  MainTableViewCell.swift
//  SwiftOverload
//
//  Created by Milan de Ruiter on 03-07-17.
//  Copyright © 2017 Milan de Ruiter. All rights reserved.
//

import UIKit

class MainTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var cellSubLabel: UILabel!
    
    enum editingViewType {
        case enabled
        case disabled
    }
    
    func render(for name:String, sub:String? = "") {
        self.selectionStyle = .none
        
        let font:UIFont = UIFont(name: "HelveticaNeue-thin", size: 18)!
        let fontSmall:UIFont = UIFont(name: "HelveticaNeue-thin", size: 14)!
        
        cellLabel.attributedText = nil
        cellLabel.text = name
        cellLabel.font = font
        cellLabel.alpha = 1
        cellLabel.textColor = UIColor.black
        cellView.alpha = 1
        cellView.isHidden = true
        
        cellSubLabel.font = fontSmall
        cellSubLabel.text = sub
        
    }
    
    func setEditingView(_ type:editingViewType? = .enabled) {
        
        cellView.isHidden = false
        cellView.subviews.forEach { view in
            view.removeFromSuperview()
        }
        cellView.subviews.last?.removeFromSuperview()
        
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: cellLabel.text!)
        attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 1, range: NSMakeRange(0, attributeString.length))
        
        setViewImage(state: .enabled)
        
        if(type == .disabled) {
            setViewImage(state: .disabled)
            cellLabel.attributedText = attributeString
            cellLabel.alpha = 0.3
            cellView.alpha = 0.3
        }
    }
    
    func setViewImage(state:editingViewType) {
        var img:UIImage = UIImage(named: "icon_eye_open")!
        
        if state == .disabled {
            img = UIImage(named: "icon_eye_closed")!
        }
        
        let imgView:UIImageView = UIImageView(frame: CGRect(x: cellView.frame.size.width - 20, y: 5, width: 20, height: 20))
        imgView.image = img
        cellView.addSubview(imgView)
        
    }
}
