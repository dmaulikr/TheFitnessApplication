//
//  Player.swift
//  SwiftOverload
//
//  Created by Milan de Ruiter on 12-07-17.
//  Copyright © 2017 Milan de Ruiter. All rights reserved.
//

import Foundation

class Player: NSObject, NSCoding {
    
    //MARK: Properties
    
    var id: Int
    var experience: Int
    
    //MARK: Initializers
    
    init(id: Int, experience: Int) {
        self.id = id
        self.experience = experience
    }
    
    init(with resultSet: FMResultSet) {
        self.id = Int(resultSet.int(forColumn: "id"))
        self.experience = Int(resultSet.int(forColumn: "experience"))
    }
    
    //MARK: Encoders
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.experience, forKey: "experience")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeInteger(forKey: "id")
        self.experience = aDecoder.decodeInteger(forKey: "experience")
    }
}


