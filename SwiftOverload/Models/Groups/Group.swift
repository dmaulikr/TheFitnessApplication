//
//  Group.swift
//  SwiftOverload
//
//  Created by Milan de Ruiter on 06-07-17.
//  Copyright © 2017 Milan de Ruiter. All rights reserved.
//

import Foundation

class Group: NSObject, NSCoding {
    
    //MARK: Properties
    
    var id: Int
    var name: String
    var muscle_id: Int
    
    //MARK: Initializers
    
    init(id: Int, name: String, muscle_id: Int) {
        self.id = id
        self.name = name
        self.muscle_id = muscle_id
    }
    
    init(with resultSet: FMResultSet) {
        self.id = Int(resultSet.int(forColumn: "id"))
        self.name = resultSet.string(forColumn: "name")! as String
        self.muscle_id = Int(resultSet.int(forColumn: "muscle_id"))
    }
    
    //MARK: Encoders
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: "exercize_id")
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.muscle_id, forKey: "muscle_id")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeInteger(forKey: "exercize_id")
        self.name = aDecoder.decodeObject(forKey: "name") as! String
        self.muscle_id = aDecoder.decodeInteger(forKey: "muscle_id")
    }
}

