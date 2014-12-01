//
//  Line.swift
//  TouchTracker
//
//  Created by FRANCIS HUYNH on 11/30/14.
//  Copyright (c) 2014 Fhools. All rights reserved.
//

import Foundation
import UIKit
class Line : NSObject {
    var begin : CGPoint
    var end : CGPoint
    
    init(begin: CGPoint, end: CGPoint) {
        self.begin = begin
        self.end = end
    }
    
    func description() -> String {
        return "Line(\(self.begin) \(self.end))"
    }
}