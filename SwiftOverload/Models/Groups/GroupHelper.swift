//
//  GroupHelper.swift
//  SwiftOverload
//
//  Created by Milan de Ruiter on 06-07-17.
//  Copyright © 2017 Milan de Ruiter. All rights reserved.
//

import Foundation

class GroupHelper {
    static let sharedInstance = GroupHelper()
    
    //MARK: - Initializers
    
    private init() { }
    
    class func getInstance() -> GroupHelper {
        return sharedInstance
    }
    
    //MARK: - Getters
    
    func getAllGroups(for muscle:Int) -> [Group] {
        var dataArray:[Group] = []
        
        DatabaseHelper.sharedInstance.openDatabase()
        
        if let resultSet:FMResultSet = DatabaseHelper.sharedInstance.execute(query: "SELECT * FROM groups WHERE muscle_id = \(muscle)") {
            while resultSet.next() {
                let group:Group = Group(with: resultSet)
                dataArray.append(group)
            }
        }
        
        DatabaseHelper.sharedInstance.closeDatabase()
        
        return dataArray
    }
    
    //MARK: - Setters
    
    
}

