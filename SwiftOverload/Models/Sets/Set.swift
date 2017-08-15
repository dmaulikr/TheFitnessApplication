//
//  Set.swift
//  SwiftOverload
//
//  Created by Milan de Ruiter on 06-07-17.
//  Copyright © 2017 Milan de Ruiter. All rights reserved.
//

import Foundation

class Set: NSObject, NSCoding {
    
    //MARK: Properties
    
    var id: Int
    var exercize: Int
    var weight: Int
    var reputition: Int
    var date: String
    
    //MARK: Initializers
    
    init(id: Int, exercize: Int, weight: Int, reputition: Int, date: String) {
        self.id = id
        self.exercize = exercize
        self.weight = weight
        self.reputition = reputition
        self.date = date
    }
    
    init(with resultSet: FMResultSet) {
        self.id = Int(resultSet.int(forColumn: "id"))
        self.exercize = Int(resultSet.int(forColumn: "exercize_id"))
        self.weight = Int(resultSet.int(forColumn: "weight"))
        self.reputition = Int(resultSet.int(forColumn: "reputition"))
        self.date = resultSet.string(forColumn: "date")!
    }
    
    //MARK: Encoders
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.exercize, forKey: "exercize_id")
        aCoder.encode(self.weight, forKey: "weight")
        aCoder.encode(self.reputition, forKey: "reputition")
        aCoder.encode(self.date, forKey: "date")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeInteger(forKey: "id")
        self.exercize = aDecoder.decodeInteger(forKey: "exercize_id")
        self.weight = aDecoder.decodeInteger(forKey: "weight")
        self.reputition = aDecoder.decodeInteger(forKey: "reputition")
        self.date = aDecoder.decodeObject(forKey: "date") as! String
    }
}


