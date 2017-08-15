//
//  StringExtension.swift
//  SwiftOverload
//
//  Created by Milan de Ruiter on 07-07-17.
//  Copyright © 2017 Milan de Ruiter. All rights reserved.
//

import UIKit

extension String {
    
    func toDate() -> Date {
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let formattedDate = dateFormatter.date(from: self) {
            return formattedDate
        }
        return Date()
    }
    
    func toDateString() -> String {
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mms:ss"
        
        let date = dateFormatter.date(from: self)
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let formattedDate:String = dateFormatter.string(from: date!)
        return formattedDate
    }
    
    func toDateTime() -> Date {
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let formattedDate = dateFormatter.date(from: self) {
            return formattedDate
        }
        return Date()
    }
    
}

