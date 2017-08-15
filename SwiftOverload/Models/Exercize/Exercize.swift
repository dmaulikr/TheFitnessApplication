//
//  Exercize.swift
//  SwiftOverload
//
//  Created by Milan de Ruiter on 06-07-17.
//  Copyright © 2017 Milan de Ruiter. All rights reserved.
//

import Foundation

class Exercize: NSObject, NSCoding {
    
    //MARK: Properties
    
    var id: Int
    var name: String
    var group_id: Int
    var last: Set?
    
    //MARK: Initializers
    
    init(id: Int, name: String, group_id: Int) {
        self.id = id
        self.name = name
        self.group_id = group_id
    }
    
    init(with resultSet: FMResultSet) {
        self.id = Int(resultSet.int(forColumn: "id"))
        self.name = resultSet.string(forColumn: "name")! as String
        self.group_id = Int(resultSet.int(forColumn: "group_id"))
    }
    
    //MARK: Encoders
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.group_id, forKey: "group_id")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeInteger(forKey: "id")
        self.name = aDecoder.decodeObject(forKey: "name") as! String
        self.group_id = aDecoder.decodeInteger(forKey: "group_id")
    }
    
}

