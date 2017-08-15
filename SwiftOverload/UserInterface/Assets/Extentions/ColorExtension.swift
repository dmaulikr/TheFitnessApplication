//
//  ColorExtension.swift
//  SwiftOverload
//
//  Created by Milan de Ruiter on 12-07-17.
//  Copyright © 2017 Milan de Ruiter. All rights reserved.
//

import UIKit

extension UIColor {
    
    class var customGray: UIColor {
        return createRGB(245, 245, 245)
    }
    
    class var customDarkGray: UIColor {
        return createRGB(102, 102, 102)
    }
    
    class var customRed: UIColor {
        return createRGB(246, 71, 71)
    }
    
    class var customGreen: UIColor {
        return createRGB(0, 177, 106)
    }
    
    class var customOrange: UIColor {
        return createRGB(254, 94, 0)
    }
    
    class var customYellow: UIColor {
        return createRGB(254, 192, 65)
    }
    
    class var customBlue: UIColor {
        return createRGB(68, 146, 216)
    }
    
    private class func createRGB(_ colorRed:Float, _ colorGreen:Float, _ colorBlue:Float) -> UIColor {
        let red = Float(colorRed/255)
        let blue = Float(colorBlue/255)
        let green = Float(colorGreen/255)
        return UIColor(colorLiteralRed: red, green: green, blue: blue, alpha: 1)
    }
    
}


