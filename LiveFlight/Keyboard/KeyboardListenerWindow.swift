//
//  KeyboardListenerWindow.swift
//  LiveFlight
//
//  Created by Cameron Carmichael Alonso on 26/12/2015.
//  Copyright © 2015 Cameron Carmichael Alonso. All rights reserved.
//

import Cocoa

//
// List of Apple keyboard keyCodes
// http://macbiblioblog.blogspot.com.es/2014/12/key-codes-for-function-and-special-keys.html
//

class KeyboardListenerWindow: NSWindow {
    var connector = InfiniteFlightAPIConnector()
    let controls = FlightControls()
    var keydown = false
    
    var shiftPressed = false
    
    //MARK - keyboard events
    override func keyDown(with event: NSEvent)
    {
        NSLog("keyDown: \(event.keyCode)!")
        
        if (event.keyCode == 0) {
            //A key
            if (keydown != true) {
                connector.atcMenu()
            }
            keydown = true
        } else if (event.keyCode == 18) {
            //1 key
            if (keydown != true) {
                connector.atc1()
            }
            keydown = true
        } else if (event.keyCode == 19) {
            //2 key
            if (keydown != true) {
                connector.atc2()
            }
            keydown = true
        } else if (event.keyCode == 20) {
            //3 key
            if (keydown != true) {
                connector.atc3()
            }
            keydown = true
        } else if (event.keyCode == 21) {
            //4 key
            if (keydown != true) {
                connector.atc4()
            }
            keydown = true
        } else if (event.keyCode == 23) {
            //5 key
            if (keydown != true) {
                connector.atc5()
            }
            keydown = true
        } else if (event.keyCode == 22) {
            //6 key
            if (keydown != true) {
                connector.atc6()
            }
            keydown = true
        } else if (event.keyCode == 26) {
            //7 key
            if (keydown != true) {
                connector.atc7()
            }
            keydown = true
        } else if (event.keyCode == 28) {
            //8 key
            if (keydown != true) {
                connector.atc8()
            }
            keydown = true
        } else if (event.keyCode == 25) {
            //9 key
            if (keydown != true) {
                connector.atc9()
            }
            keydown = true
        } else if (event.keyCode == 29) {
            //0 key
            if (keydown != true) {
                connector.atc10()
            }
            keydown = true
        } else if (event.keyCode == 12) {
            //A key
            if (keydown != true) {
                connector.previousCamera()
            }
            keydown = true
        } else if (event.keyCode == 14) {
            //D key
            if (keydown != true) {
                connector.nextCamera()
            }
            keydown = true
        } else if (event.keyCode == 5) {
            //G key
            if (keydown != true) {
                connector.landingGear()
            }
            keydown = true
        } else if (event.keyCode == 47) {
            //. key
            if (keydown != true) {
                connector.parkingBrakes()
            }
            keydown = true
        } else if (event.keyCode == 44) {
            // / key
            if (keydown != true) {
                connector.spoilers()
            }
            keydown = true
        } else if (event.keyCode == 35) {
            // P key
            if (keydown != true) {
                connector.pushback()
            }
            keydown = true
        } else if (event.keyCode == 49) {
            // space key
            if (keydown != true) {
                connector.togglePause()
            }
            keydown = true
        } else if (event.keyCode == 6) {
            // Z key
            if (keydown != true) {
                connector.autopilot()
            }
            keydown = true
        } else if (event.keyCode == 24) {
            // = key
            if (keydown != true) {
                connector.zoomIn()
            }
            keydown = true
        } else if (event.keyCode == 27) {
            // - key
            if (keydown != true) {
                connector.zoomOut()
            }
            keydown = true
        } else if (event.keyCode == 30) {
            // ] key
            if (keydown != true) {
                connector.flapsDown()
            }
            keydown = true
        } else if (event.keyCode == 33) {
            // [ key
            if (keydown != true) {
                connector.flapsUp()
            }
            keydown = true
        } else if (event.keyCode == 37) {
            // L key
            if (keydown != true) {
                connector.landing()
            }
            keydown = true
        } else if (event.keyCode == 45) {
            // N key
            if (keydown != true) {
                connector.nav()
            }
            keydown = true
        } else if (event.keyCode == 11) {
            // B key
            if (keydown != true) {
                connector.beacon()
            }
            keydown = true
        } else if (event.keyCode == 1) {
            // S key
            if (keydown != true) {
                connector.strobe()
            }
            keydown = true
        } else if (event.keyCode == 123) {
            
            // - The following don't need the keyDown bool; timing is handled by InfiniteFlightAPIConnector
            
            // left arrow key
            
            if shiftPressed != true {
            
                controls.leftArrow()
         
            } else {
                
                // move camera left
                connector.movePOV(withValue: 270)
                
            }
            
        } else if (event.keyCode == 124) {
            // right arrow key
            
            if shiftPressed != true {
                
                controls.rightArrow()

            } else {
                
                // move camera right
                connector.movePOV(withValue: 90)
                
            }
                
        } else if (event.keyCode == 126) {
            // up arrow key
            
            if shiftPressed != true {
                
                controls.upArrow()

                
            } else {
                
                // move camera up
                connector.movePOV(withValue: 0)
                
            }
        
        } else if (event.keyCode == 125) {
            // down arrow key
           
            if shiftPressed != true {
                
                controls.downArrow()
                
            } else {
                
                // move camera down
                connector.movePOV(withValue: 180)
                
            }
            
        } else if (event.keyCode == 2) {
            // D key
            
            controls.throttleUpArrow()
            
        } else if (event.keyCode == 8) {
            // C arrow key
            
            controls.throttleDownArrow()
            
        }
        
        
        /*
        // TODO - send keyboard commands as buttons. issue with alternate cmds.
        connector.didPressButton(Int32(event.keyCode), state: 0)
        keydown = true
        */
        
    }
    
    func keyUp(event: NSEvent)
    {
        //connector.didPressButton(Int32(event.keyCode), state: 1)
        connector.movePOV(withValue: -2)
        keydown = false
    }
    
    func flagsChanged(event: NSEvent) {
        switch event.modifierFlags.intersection(NSDeviceIndependentModifierFlagsMask) {
        case NSShiftKeyMask :
            NSLog("Shift key pressed")
            shiftPressed = true
        case NSControlKeyMask:
            NSLog("Control Pressed..")
        case NSAlternateKeyMask :
            NSLog("Option pressend...")
        case NSCommandKeyMask:
            NSLog("Command key pressed..")
        default:
            NSLog("No modifier keys pressed")
            shiftPressed = false
        }
    }
    
}
