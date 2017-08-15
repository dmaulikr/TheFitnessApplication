//
//  DateExtension.swift
//  SwiftOverload
//
//  Created by Milan de Ruiter on 07-07-17.
//  Copyright © 2017 Milan de Ruiter. All rights reserved.
//

import UIKit

extension Date {
    
    func toString() -> String {
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: self)
    }
    
    func toDateString() -> String {
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }
    
}
