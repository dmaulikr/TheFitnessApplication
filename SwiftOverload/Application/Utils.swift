//
//  Utils.swift
//  SwiftOverload
//
//  Created by Milan de Ruiter on 06-07-17.
//  Copyright © 2017 Milan de Ruiter. All rights reserved.
//

import UIKit

class Utils: NSObject {
    
    class func getPath(fileName: String) -> String {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(fileName)
        return fileURL.path
    }
    
    class func copyFile(fileName: NSString) {
        let dbPath: String = getPath(fileName: fileName as String)
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: dbPath) {
            let documentsURL = Bundle.main.resourceURL
            let fromPath = documentsURL!.appendingPathComponent(fileName as String)
            
            var error : NSError?
            do {
                try fileManager.copyItem(atPath: fromPath.path, toPath: dbPath)
            } catch let error1 as NSError {
                error = error1
            }
            
            if error != nil && error?.description != "" {
                print(error?.description ?? "Error occured")
            }
        }
    }
    
    class func getRandom(max:Float? = 1, min:Float? = 0) -> Float {
        return (Float(arc4random()) / 0xFFFFFFFF) * (max! - min!) + min!
    }
    
    // MARK: Userdefaults
    
    class func getDefaults(for string:String) -> [Any] {
        var arr:[Any] = []
        let defaults:UserDefaults = UserDefaults.standard
        if let array = defaults.array(forKey: string) {
            for obj in array {
                if let object = NSKeyedUnarchiver.unarchiveObject(with: obj as! Data) {
                    arr.append(object)
                }
            }
        }
        return arr
    }
    
    class func setDefaults(_ data:[Data], for key:String) {
        let defaults:UserDefaults = UserDefaults.standard
        defaults.set(data, forKey: key)
        defaults.synchronize()
    }
    
}
