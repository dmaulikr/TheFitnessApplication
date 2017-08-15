//
//  Graph.swift
//  SwiftOverload
//
//  Created by Milan de Ruiter on 21-07-17.
//  Copyright © 2017 Milan de Ruiter. All rights reserved.
//

import UIKit
import CoreGraphics
import Foundation

class Graph: UIView {
    
    @IBInspectable var startColor = UIColor.gray
    @IBInspectable var endColor = UIColor.customDarkGray
    
    var weightPoints:[Int] = [0, 0]
    var repPoints:[Int] = [0, 0]
    
    override func draw(_ rect: CGRect) {
        
        let width = rect.width
        let height = rect.height
        let margin:CGFloat = 10.0
        let topBorder:CGFloat = 15
        let bottomBorder:CGFloat = 25
        let graphHeight = height - topBorder - bottomBorder
        
        let context = UIGraphicsGetCurrentContext()
        let colors = [startColor.cgColor, endColor.cgColor]
        let bgColors = [UIColor.customDarkGray.cgColor, UIColor.customDarkGray.cgColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations:[CGFloat] = [0.0, 1.0]
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: colorLocations)
        let bgGradient = CGGradient(colorsSpace: colorSpace, colors: bgColors as CFArray, locations: colorLocations)
        
        var startPoint = CGPoint.zero
        var endPoint = CGPoint(x: 0, y: self.bounds.height)
        
        context?.drawLinearGradient(bgGradient!, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
        
        
        let columnXPoint = { (column:Int) -> CGFloat in
            //Calculate gap between points
            let spacer = (width - margin * 2 - 29) /
                CGFloat((self.weightPoints.count - 1))
            var x:CGFloat = CGFloat(column) * spacer
            x += margin + 2
            return x
        }
        
        // calculate the y point
        
        let max = weightPoints.max()
        let min = weightPoints.min()
        
        let top = 10 * Int(round(Double(max! / 10)))
        let newMax:Int = top + 10
        
        let newMin = 10 * Int(round(Double(min! / 10)))
        
        let columnYPoint = { (graphPoint:Int) -> CGFloat in
            
            let temp = graphPoint-newMin;
            let graphRange = newMax - newMin
            
            var y:CGFloat = CGFloat(temp) / CGFloat(graphRange) * graphHeight
            y = graphHeight + topBorder - y
            
            return y
        }
        
        // draw the line graph
        UIColor.customBlue.setFill()
        UIColor.customBlue.setStroke()
        
        
        //set up the points line
        let graphPath = UIBezierPath()
        //go to start of line
        graphPath.move(to: CGPoint(x:columnXPoint(0),
                                   y:columnYPoint(weightPoints[0])))
        
        //add points for each item in the weightPoints array
        //at the correct (x, y) for the point
        for i in 1..<weightPoints.count {
            let nextPoint = CGPoint(x:columnXPoint(i),
                                    y:columnYPoint(weightPoints[i]))
            graphPath.addLine(to: nextPoint)
        }
        
        //Create the clipping path for the graph gradient
        
        //1 - save the state of the context (commented out for now)
        context!.saveGState()
        
        //2 - make a copy of the path
        let clippingPath = graphPath.copy() as! UIBezierPath
        
        //3 - add lines to the copied path to complete the clip area
        clippingPath.addLine(to: CGPoint( x: columnXPoint(weightPoints.count - 1), y:height))
        clippingPath.addLine(to: (CGPoint( x:columnXPoint(0), y:height)))
        clippingPath.close()
        
        //4 - add the clipping path to the context
        clippingPath.addClip()
        
        let highestYPoint = columnYPoint(max!)
        startPoint = CGPoint(x:margin, y: highestYPoint)
        endPoint = CGPoint(x:margin, y:self.bounds.height)
        
        context!.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
        context!.restoreGState()
        
        UIColor.customBlue.setFill()
        UIColor.white.setStroke()
        
        //draw the line on top of the clipped gradient
        graphPath.lineWidth = 0.5
        graphPath.stroke()
        
        //Draw the circles on top of graph stroke
        for i in 0..<weightPoints.count {
            var size:CGSize = CGSize(width: 8, height: 8)
            var point = CGPoint(x: columnXPoint(i) - (size.width / 2), y: columnYPoint(weightPoints[i]) - (size.height / 2) )
            let circle = UIBezierPath(ovalIn: CGRect(origin: point, size: size))
            circle.fill()
        }
        
        //Draw the labels
        for i in 0..<weightPoints.count {
            var point = CGPoint(x: columnXPoint(i), y: columnYPoint(weightPoints[i]))
            point.y += 8
            let attribute:NSDictionary = [NSForegroundColorAttributeName:UIColor.white]
            let attributedString = NSAttributedString(string: "\(weightPoints[i]) kg", attributes: attribute as! [String : Any])
            attributedString.draw(at: point)
        }
        
        //Draw horizontal graph lines on the top of everything
        let linePath = UIBezierPath()
        
        //top line
        linePath.move(to: CGPoint(x:margin, y: topBorder))
        linePath.addLine(to: CGPoint(x: width - margin, y:topBorder))
        
        //center line
        linePath.move(to: CGPoint(x:margin, y: graphHeight/2 + topBorder))
        linePath.addLine(to: CGPoint(x:width - margin, y:graphHeight/2 + topBorder))
        
        //bottom line
        linePath.move(to: CGPoint(x:margin, y:height - bottomBorder))
        linePath.addLine(to: CGPoint(x:width - margin, y:height - bottomBorder))
        let color = UIColor.customGray.withAlphaComponent(0.1)
        color.setStroke()
        
        linePath.lineWidth = 1.0
        linePath.stroke()
        
        //Draw the bars
        for i in 0..<weightPoints.count {
            
            let fullHeight:Float = Float(graphHeight + topBorder - 10)
            let maxRep:Float = Float(repPoints.max()!)
            let curRep:Float = Float(repPoints[i])
            
            let size:Float = Float( curRep / maxRep ) * Float(topBorder + bottomBorder)
            
            let pointTop = CGPoint(x:columnXPoint(i), y:CGFloat(fullHeight - size))
            let pointBottom = CGPoint(x:columnXPoint(i), y:graphHeight + topBorder)
            
            let barPath = UIBezierPath()
            
            barPath.move(to: pointTop)
            barPath.addLine(to: pointBottom)
            
            UIColor.lightGray.withAlphaComponent(0.4).setStroke()
            barPath.lineWidth = 5.0
            barPath.stroke()
        }
        
    }
    
}













