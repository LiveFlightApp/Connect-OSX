//
//  JoystickReady.swift
//  LiveFlight
//
//  Created by Cameron Carmichael Alonso on 30/12/2015.
//  Copyright © 2015 Cameron Carmichael Alonso. All rights reserved.
//

import Cocoa

class JoystickReady: NSView {

    override init(frame frameRect: NSRect) {
        super.init(frame:frameRect)
        
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)!
        
        // set the background for the all clear view
        self.backgroundColor = NSColor(calibratedRed: (130.0/255.0), green: (130.0/255.0), blue: (130.0/255.0), alpha: 0.9)
        

    }

}
