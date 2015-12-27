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
    var keydown = false
    
    //MARK - keyboard events
    override func keyDown(event: NSEvent)
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
        }
        
        
        /*
        // TODO - send keyboard commands as buttons. issue with alternate cmds.
        connector.didPressButton(Int32(event.keyCode), state: 0)
        keydown = true
        */
        
    }
    
    override func keyUp(event: NSEvent)
    {
        NSLog("keyUp")
        //connector.didPressButton(Int32(event.keyCode), state: 1)
        keydown = false
    }
    
    override func flagsChanged(event: NSEvent) {
        switch event.modifierFlags.intersect(.DeviceIndependentModifierFlagsMask) {
        case NSEventModifierFlags.ShiftKeyMask :
            NSLog("Shift key pressed")
        case NSEventModifierFlags.ControlKeyMask:
            NSLog("Control Pressed..")
        case NSEventModifierFlags.AlternateKeyMask :
            NSLog("Option pressend...")
        case NSEventModifierFlags.CommandKeyMask:
            NSLog("Command key  pressed..")
        default:
            NSLog("No modifier keys pressed")
        }
    }
    
}