//
//  DrawView.swift
//  TouchTracker
//
//  Created by FRANCIS HUYNH on 11/30/14.
//  Copyright (c) 2014 Fhools. All rights reserved.
//

import Foundation
import UIKit
class DrawView : UIView , UIGestureRecognizerDelegate {
    var finishedLines = [Line]()
    var linesInProgress = [NSValue:Line]()
    var currentLine: Line?
    var selectedLine: Line?
    var moveGestureRecognizer : UIPanGestureRecognizer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.grayColor()
        self.multipleTouchEnabled = true
        
        var tapRecognizer = UITapGestureRecognizer(target: self, action: "doubleTap:")
        
        tapRecognizer.numberOfTapsRequired = 2
        tapRecognizer.delaysTouchesBegan = true
        
        self.addGestureRecognizer(tapRecognizer)
        
        var singleTap = UITapGestureRecognizer(target: self, action: "tap:")
        singleTap.delaysTouchesBegan = true
        singleTap.requireGestureRecognizerToFail(tapRecognizer)
        self.addGestureRecognizer(singleTap)
        
        var longPressGr = UILongPressGestureRecognizer(target: self, action: "longPress:")
        self.addGestureRecognizer(longPressGr)
        
        self.moveGestureRecognizer = UIPanGestureRecognizer(target: self, action: "moveLine:")
        self.moveGestureRecognizer?.delegate = self
        self.moveGestureRecognizer?.cancelsTouchesInView = false
        self.addGestureRecognizer(self.moveGestureRecognizer!)
        
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
        
        // Interesting that we don't need to erase the 
        // canvas from previous draws
        // For example when doubleTap occurs to remove all lines
        // The drawRect won't draw any lines, as if we erased canvas
        UIColor.blackColor().set()
        for line in finishedLines {
            self.strokeLine(line)
        }
        
        UIColor.redColor().set()
        for (key,line) in linesInProgress {
            self.strokeLine(line)
        }
        
        if (selectedLine != nil) {
            UIColor.greenColor().set()
            self.strokeLine(self.selectedLine!)
        }
        
    }
    
    func lineAtPoint(point: CGPoint) -> Line? {
        for line in self.finishedLines {
            var start = line.begin
            var end = line.end
            for var t:Double = 0.0; t <= 1.0; t += 0.05 {
                var x = Double(start.x) + t * (Double(end.x) - Double(start.x))
                var y = Double(start.y) + t * (Double(end.y) - Double(start.y))
                if hypot(x - Double(point.x), y - Double(point.y)) < 20 {
                    return line
                }
            }
        }
        return nil
    }
    
    // MARK: UIGestureRecognizerDelegate 
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer == self.moveGestureRecognizer) {
            return true
        }
        return false
    }
    // MARK: Gestures Actions
    func doubleTap(gr: UIGestureRecognizer) {
        println("Recognize double tap")
        self.linesInProgress.removeAll(keepCapacity: false)
        self.finishedLines.removeAll(keepCapacity: false)
        self.selectedLine = nil
        self.setNeedsDisplay()
    }
    
    func tap(gr: UIGestureRecognizer) {
        println("Single Tap")
        var point = gr.locationInView(self)
        self.selectedLine = lineAtPoint(point)
        
        if selectedLine != nil {
            self.becomeFirstResponder()
            var menu = UIMenuController.sharedMenuController()
            
            var deleteMenuItem = UIMenuItem(title: "Delete", action: "deleteLine:")
            
            menu.menuItems = [deleteMenuItem]
            menu.setTargetRect(CGRect(x: point.x, y: point.y, width: 2.0, height: 2.0), inView: self)
            menu.setMenuVisible(true, animated: true)
            
        } else {
            UIMenuController.sharedMenuController().setMenuVisible(false, animated: true)
        }
        self.setNeedsDisplay()
        
    }
    
    func longPress(gr: UIGestureRecognizer) {
        if (gr.state == UIGestureRecognizerState.Began) {
            var point = gr.locationInView(self)
            self.selectedLine = lineAtPoint(point)
            if (self.selectedLine != nil) {
                self.linesInProgress.removeAll(keepCapacity: false)
            }
        } else if (gr.state == UIGestureRecognizerState.Ended) {
            self.selectedLine = nil
        }
        self.setNeedsDisplay()
    }
    
    func deleteLine(sender: AnyObject?) {
        if let index = find(self.finishedLines, self.selectedLine!) {
            self.finishedLines.removeAtIndex(index)
            self.selectedLine = nil
        }
        self.setNeedsDisplay()
        
    }
    
    func moveLine(gr: UIPanGestureRecognizer) {
        if (self.selectedLine == nil) {
            return
        }
        if (gr.state == UIGestureRecognizerState.Changed) {
            var translation = gr.translationInView(self)
            var begin = self.selectedLine!.begin
            var end = self.selectedLine!.end
            begin.x += translation.x
            begin.y += translation.y
            end.x += translation.x
            end.y += translation.y
            
            self.selectedLine!.begin = begin
            self.selectedLine!.end = end
            self.setNeedsDisplay()
            gr.setTranslation(CGPointZero, inView: self)
        }
        
    }
    // MARK: Responder
    override func canBecomeFirstResponder() -> Bool {
        return true
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