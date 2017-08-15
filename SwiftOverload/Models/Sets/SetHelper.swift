//
//  SetHelper.swift
//  SwiftOverload
//
//  Created by Milan de Ruiter on 06-07-17.
//  Copyright © 2017 Milan de Ruiter. All rights reserved.
//

import Foundation

class SetHelper {
    static let sharedInstance = SetHelper()
    
    //MARK: - Initializers
    
    private init() { }
    
    class func getInstance() -> SetHelper {
        return sharedInstance
    }
    
    //MARK: - Getters
    
    func getAllSets(for exercize:Int) -> [Set] {
        var dataArray:[Set] = []
        
        DatabaseHelper.sharedInstance.openDatabase()
        
        if let resultSet:FMResultSet = DatabaseHelper.sharedInstance.execute(query: "SELECT * FROM sets WHERE exercize_id = \(exercize) ORDER BY date DESC") {
            while resultSet.next() {
                let set:Set = Set(with: resultSet)
                dataArray.append(set)
            }
        }
        
        DatabaseHelper.sharedInstance.closeDatabase()
        
        return dataArray
    }
    
    func getLastSet(for exercize:Int) -> Set? {
        if let resultSet:FMResultSet = DatabaseHelper.sharedInstance.execute(query: "SELECT * FROM sets WHERE exercize_id = \(exercize) ORDER BY date DESC LIMIT 1") {
            while resultSet.next() {
                let set:Set = Set(with: resultSet)
                return set;
            }
        }
        return nil
    }
    
    func getAllSets(for date:Date) -> [Set] {
        var dataArray:[Set] = []
        let dateString = date.toDateString()
        DatabaseHelper.sharedInstance.openDatabase()
        
        if let resultSet:FMResultSet = DatabaseHelper.sharedInstance.execute(query: "SELECT * FROM sets WHERE date LIKE '\(dateString)%' ") {
            while resultSet.next() {
                let set:Set = Set(with: resultSet)
                dataArray.append(set)
            }
        }
        
        DatabaseHelper.sharedInstance.closeDatabase()
        
        return dataArray
    }
    
    //MARK: - Setters
    
    func create(for exercize:Int, rep:Int, weight:Int, date:String, completionHandler:(Bool) -> () ) {
        let data:[Any] = [exercize, weight, rep, date]
        
        DatabaseHelper.sharedInstance.openDatabase()
        DatabaseHelper.sharedInstance.database?.executeUpdate("INSERT into sets (exercize_id, weight, reputition, date) values(?, ?, ?, ?)", withArgumentsIn: data)
        DatabaseHelper.sharedInstance.closeDatabase()
        
        completionHandler(true)
    }
    
    func update(set:Set, rep:Int, weight:Int, completionHandler:(Bool, NSError?) -> () ) {
        DatabaseHelper.sharedInstance.openDatabase()
        do {
            try DatabaseHelper.sharedInstance.database?.executeUpdate("UPDATE sets set reputition = ?, weight = ? where id = ?", values: [rep, weight, set.id])
            completionHandler(true, nil)
        }
        catch let error as NSError {
            completionHandler(false, error)
        }
        DatabaseHelper.sharedInstance.closeDatabase()
    }
    
    func destroy(set:Set, completionHandler:(Bool, NSError?) -> () ) {
        DatabaseHelper.sharedInstance.openDatabase()
        do {
            try DatabaseHelper.sharedInstance.database?.executeUpdate("DELETE from sets where id = ?", values: [set.id])
            completionHandler(true, nil)
        }
        catch let error as NSError {
            completionHandler(false, error)
        }
        DatabaseHelper.sharedInstance.closeDatabase()
    }
}


