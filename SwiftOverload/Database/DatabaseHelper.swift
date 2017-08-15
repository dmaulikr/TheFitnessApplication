//
//  DatabaseHelper.swift
//  SwiftOverload
//
//  Created by Milan de Ruiter on 06-07-17.
//  Copyright © 2017 Milan de Ruiter. All rights reserved.
//

import UIKit

class DatabaseHelper {
    static let sharedInstance = DatabaseHelper()
    var database:FMDatabase?
    
    //MARK: - Initializers
    
    private init() { }
    
    class func getInstance() -> DatabaseHelper {
        if sharedInstance.database == nil {
            sharedInstance.database = FMDatabase(path: Utils.getPath(fileName: "SwiftOverload.sql"))
        }
        return sharedInstance
    }
    
    //MARK: - Database connections
    
    func openDatabase() {
        DatabaseHelper.getInstance().database!.open()
    }
    
    func closeDatabase() {
        DatabaseHelper.sharedInstance.database!.close()
    }
    
    //MARK: - Executions
    
    func execute(query: String, arguments:[Any]? = []) -> FMResultSet? {
        if let resultSet:FMResultSet = DatabaseHelper.sharedInstance.database?.executeQuery(query, withArgumentsIn: arguments!){
            return resultSet
        }
        
        return nil
    }
    
}



