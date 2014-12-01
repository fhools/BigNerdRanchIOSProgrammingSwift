//
//  DrawViewController.swift
//  TouchTracker
//
//  Created by FRANCIS HUYNH on 11/30/14.
//  Copyright (c) 2014 Fhools. All rights reserved.
//

import Foundation
import UIKit
class DrawViewController : UIViewController {
    override func loadView() {
        // TODO:
        self.view = DrawView(frame: CGRectZero)
    }
}