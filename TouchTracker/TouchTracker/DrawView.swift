//
//  DrawView.swift
//  TouchTracker
//
//  Created by FRANCIS HUYNH on 11/30/14.
//  Copyright (c) 2014 Fhools. All rights reserved.
//

import Foundation
import UIKit
class DrawView : UIView {
    var finishedLines = [Line]()
    var currentLine : Line?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.grayColor()
        
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func strokeLine(line: Line) {
        var path = UIBezierPath()
        path.lineWidth = 10;
        path.lineCapStyle = kCGLineCapRound
        path.moveToPoint(line.begin)
        path.addLineToPoint(line.end)
        path.stroke()
    }
    
    override func drawRect(rect: CGRect) {
        UIColor.blackColor().set()
        for line in finishedLines {
            self.strokeLine(line)
        }
        
        if let currentLine = currentLine? {
            UIColor.redColor().set()
            self.strokeLine(currentLine)
        }
    }
    
    // MARK: Touches
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        var t = touches.anyObject() as UITouch
        var location = t.locationInView(self)
        currentLine = Line(begin: location, end: location)
        println(currentLine)
        self.setNeedsDisplay()
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        var t = touches.anyObject() as UITouch
        var location = t.locationInView(self)
        currentLine?.end = location
        println(currentLine)
        self.setNeedsDisplay()
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        var t = touches.anyObject() as UITouch
        currentLine?.end = t.locationInView(self)
        finishedLines.append(currentLine!)
        
    }
}