//
//  MuscleHelper.swift
//  SwiftOverload
//
//  Created by Milan de Ruiter on 06-07-17.
//  Copyright © 2017 Milan de Ruiter. All rights reserved.
//

import Foundation

class MuscleHelper {
    static let sharedInstance = MuscleHelper()
    
    //MARK: - Initializers
    
    private init() { }
    
    class func getInstance() -> MuscleHelper {
        return sharedInstance
    }
    
    //MARK: - Getters
    
    func getAllMuscles() -> [Muscle] {
        var dataArray:[Muscle] = []
        
        DatabaseHelper.sharedInstance.openDatabase()
        
        if let resultSet:FMResultSet = DatabaseHelper.sharedInstance.execute(query: "SELECT * FROM muscles") {
            while resultSet.next() {
                let muscle:Muscle = Muscle(with: resultSet)
                dataArray.append(muscle)
            }
        }
        
        DatabaseHelper.sharedInstance.closeDatabase()
        
        return dataArray
    }
    
    //MARK: - Setters
    
    func update(muscle:Muscle, to name:String, completionHandler:(Bool, NSError?) -> () ) {
        DatabaseHelper.sharedInstance.openDatabase()
        do {
            try DatabaseHelper.sharedInstance.database?.executeUpdate("UPDATE muscles set name = ? where id = ?", values: [name, muscle.id])
            completionHandler(true, nil)
        }
        catch let error as NSError {
            completionHandler(false, error)
        }
        DatabaseHelper.sharedInstance.closeDatabase()
    }
    
}
