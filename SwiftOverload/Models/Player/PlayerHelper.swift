//
//  PlayerHelper.swift
//  SwiftOverload
//
//  Created by Milan de Ruiter on 12-07-17.
//  Copyright © 2017 Milan de Ruiter. All rights reserved.
//

import Foundation

class PlayerHelper {
    static let sharedInstance = PlayerHelper()
    
    //MARK: - Initializers
    
    private init() { }
    
    class func getInstance() -> PlayerHelper {
        return sharedInstance
    }
    
    //MARK: - Getters
    
    func getPlayer() -> Player {
        var player:Player!
        
        DatabaseHelper.sharedInstance.openDatabase()
        if let resultSet:FMResultSet = DatabaseHelper.sharedInstance.execute(query: "SELECT * FROM players WHERE id = 1 ") {
            while resultSet.next() {
                player = Player(with: resultSet)
            }
        }
        DatabaseHelper.sharedInstance.closeDatabase()
        
        return player
    }
    
    //MARK: - Setters
    
    func addToHighscore(points:Int, completionHandler:(Int) -> () ) {
        
        let player:Player = getPlayer()
        let highscore:Int = player.experience
        let newHighscore:Int = highscore + points
        
        
        DatabaseHelper.sharedInstance.openDatabase()
        DatabaseHelper.sharedInstance.database?.executeUpdate("UPDATE players set experience = ? WHERE id = 1", withArgumentsIn: [newHighscore])
        DatabaseHelper.sharedInstance.closeDatabase()
        completionHandler(newHighscore)
    }
    
    
}
