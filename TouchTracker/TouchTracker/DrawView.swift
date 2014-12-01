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
    var linesInProgress = [NSValue:Line]()
    var currentLine : Line?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.grayColor()
        self.multipleTouchEnabled = true
        
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
        
        UIColor.redColor().set()
        for (key,line) in linesInProgress {
            self.strokeLine(line)
        }
        
    }
    
    // MARK: Touches
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        for t in touches {
            var touch = t as UITouch
            var location = touch.locationInView(self)
            var line = Line(begin: location, end: location)
            linesInProgress[NSValue(nonretainedObject: touch)] = line
        }
        self.setNeedsDisplay()
    }
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        for t in touches {
            var touch = t as UITouch
            linesInProgress[NSValue(nonretainedObject: touch)]?.end = touch.locationInView(self)
        }
        self.setNeedsDisplay()
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        for t in touches {
            var touch = t as UITouch
            finishedLines.append(linesInProgress[NSValue(nonretainedObject: touch)]!)
            linesInProgress.removeValueForKey(NSValue(nonretainedObject: touch))
        }
    }
}