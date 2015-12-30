//
//  JoystickReady.swift
//  LiveFlight
//
//  Created by Cameron Carmichael Alonso on 30/12/2015.
//  Copyright © 2015 Cameron Carmichael Alonso. All rights reserved.
//

import Cocoa

class Status: NSView {

    override init(frame frameRect: NSRect) {
        super.init(frame:frameRect)
        
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)!
        
        // set the background for the all clear view
        self.backgroundColor = NSColor(calibratedRed: (50.0/255.0), green: (50.0/255.0), blue: (50.0/255.0), alpha: 0.95)
        

    }

}
