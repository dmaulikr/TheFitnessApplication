//
//  ExercizeHelper.swift
//  SwiftOverload
//
//  Created by Milan de Ruiter on 06-07-17.
//  Copyright © 2017 Milan de Ruiter. All rights reserved.
//

import Foundation

class ExercizeHelper {
    static let sharedInstance = ExercizeHelper()
    
    //MARK: - Initializers
    
    private init() { }
    
    class func getInstance() -> ExercizeHelper {
        return sharedInstance
    }
    
    //MARK: - Getters
    
    func getAllExercises(for group:Int) -> [Exercize] {
        var dataArray:[Exercize] = []
        
        DatabaseHelper.sharedInstance.openDatabase()
        
        if let resultSet:FMResultSet = DatabaseHelper.sharedInstance.execute(query: "SELECT * FROM exercises WHERE group_id = \(group)") {
            while resultSet.next() {
                let exercize:Exercize = Exercize(with: resultSet)
                if let set:Set = SetHelper.sharedInstance.getLastSet(for: exercize.id) {
                    exercize.last = set
                }
                dataArray.append(exercize)
            }
        }
        
        DatabaseHelper.sharedInstance.closeDatabase()
        
        return dataArray
    }
    
    func getExercizeName(for id:Int) -> String {
        DatabaseHelper.sharedInstance.openDatabase()
        var exercizeName = ""
        if let resultSet:FMResultSet = DatabaseHelper.sharedInstance.execute(query: "SELECT name FROM exercises WHERE id = \(id)") {
            while resultSet.next() {
                exercizeName = resultSet.string(forColumn: "name")!
            }
        }
        DatabaseHelper.sharedInstance.closeDatabase()
        return exercizeName
    }
    
    //MARK: - Setters
    
    func create(exercize:String, group:Int, completionHandler:(Bool) -> () ) {
        let data:[Any] = [exercize, group]
        
        DatabaseHelper.sharedInstance.openDatabase()
        DatabaseHelper.sharedInstance.database?.executeUpdate("INSERT into exercises (name, group_id) values(?, ?)", withArgumentsIn: data)
        DatabaseHelper.sharedInstance.closeDatabase()
        
        completionHandler(true)
    }
    
    func update(exercize:Exercize, to name:String, completionHandler:(Bool, NSError?) -> () ) {
        DatabaseHelper.sharedInstance.openDatabase()
        do {
            try DatabaseHelper.sharedInstance.database?.executeUpdate("UPDATE exercises set name = ? where id = ?", values: [name, exercize.id])
            completionHandler(true, nil)
        }
        catch let error as NSError {
            completionHandler(false, error)
        }
        DatabaseHelper.sharedInstance.closeDatabase()
    }
    
    func delete(exercize:Exercize, completionHandler:(Bool, NSError?) -> () ) {
        DatabaseHelper.sharedInstance.openDatabase()
        do {
            try DatabaseHelper.sharedInstance.database?.executeUpdate("DELETE from exercises where id = ?", values: [exercize.id])
            completionHandler(true, nil)
        }
        catch let error as NSError {
            completionHandler(false, error)
        }
        DatabaseHelper.sharedInstance.closeDatabase()
    }
    
}
