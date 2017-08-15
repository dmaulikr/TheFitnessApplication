//
//  Muscle.swift
//  SwiftOverload
//
//  Created by Milan de Ruiter on 06-07-17.
//  Copyright © 2017 Milan de Ruiter. All rights reserved.
//

import Foundation

class Muscle: NSObject, NSCoding {
    
    //MARK: Properties
    
    var id: Int
    var name: String
    var type: String
    
    //MARK: Initializers
    
    init(id: Int, name: String, type: String) {
        self.id = id
        self.name = name
        self.type = type
    }
    
    init(with resultSet: FMResultSet) {
        self.id = Int(resultSet.int(forColumn: "id"))
        self.name = resultSet.string(forColumn: "name")! as String
        self.type = resultSet.string(forColumn: "type")! as String
    }
    
    //MARK: Encoders
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: "exercize_id")
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.type, forKey: "type")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeInteger(forKey: "exercize_id")
        self.name = aDecoder.decodeObject(forKey: "name") as! String
        self.type = aDecoder.decodeObject(forKey: "type") as! String
    }

}
