//
//  FlightControls.swift
//  LiveFlight
//
//  Created by Cameron Carmichael Alonso on 31/12/2015.
//  Copyright © 2015 Cameron Carmichael Alonso. All rights reserved.
//

import Cocoa

class FlightControls: NSObject {

    // init connector
    var connector = InfiniteFlightAPIConnector()
    
    /*
        // for reference - axes
        0 - pitch
        1 - roll
        2 - rudder
        3 - throttle
    */
    
    var pitchValue:Int32 = 0
    var rollValue:Int32 = 0
    var rudderValue:Int32 = 0
    var throttleValue:Int32 = 0
    
    // delta when key is pressed
    var deltaForKeyPress:Int32 = 100
    var deltaThrottleForKeyPress:Int32 = 50
    
    func pitchChanged(value:Int32) {
        
        pitchValue = value
        connector.didMoveAxis(0, value: value)
        
    }
    
    func rollChanged(value:Int32) {
        
        rollValue = value
        connector.didMoveAxis(1, value: value)
        
    }
    
    func rudderChanged(value:Int32) {
        
        rudderValue = value
        connector.didMoveAxis(2, value: value)
        
    }
    
    func throttleChanged(value:Int32) {
        
        throttleValue = value
        connector.didMoveAxis(3, value: value)
        
    }
    
    func upArrow() {
        // decrease pitch
        
        if pitchValue > -1024 {
            
            // subtract delta
            pitchValue -= deltaForKeyPress
            
            // pass command with new value
            connector.didMoveAxis(0, value: pitchValue)
            
        }
        
    }
    
    func downArrow() {
        // increase pitch
        
        if pitchValue < 1024 {
            
            // subtract delta
            pitchValue += deltaForKeyPress
            
            // pass command with new value
            connector.didMoveAxis(0, value: pitchValue)
            
        }
        
    }
    
    func leftArrow() {
        // left roll
        
        if rollValue > -1024 {
            
            // subtract delta
            rollValue -= deltaForKeyPress
            
            // pass command with new value
            connector.didMoveAxis(1, value: rollValue)
            
        }
        
    }
    
    func rightArrow() {
        // increase pitch
        
        if rollValue < 1024 {
            
            // subtract delta
            rollValue += deltaForKeyPress
            
            // pass command with new value
            connector.didMoveAxis(1, value: rollValue)
            
        }
        
    }
    
    func throttleUpArrow() {
        // increase pitch
        
        if throttleValue > -1024 {
            
            // subtract delta
            throttleValue -= deltaThrottleForKeyPress
            
            // pass command with new value
            connector.didMoveAxis(3, value: throttleValue)
            
        }
        
    }
    
    func throttleDownArrow() {
        // decrease throttle
        
        if throttleValue < 1024 {
            
            // subtract delta
            throttleValue += deltaThrottleForKeyPress
            
            // pass command with new value
            connector.didMoveAxis(3, value: throttleValue)
            
        }
        
    }
    
}
