//
//  KeyboardListenerWindow.swift
//  LiveFlight
//
//  Created by Cameron Carmichael Alonso on 26/12/2015.
//  Copyright © 2015 Cameron Carmichael Alonso. All rights reserved.
//

import Cocoa

class KeyboardListenerWindow: NSWindow {
    var connector = InfiniteFlightAPIConnector()
    var keydown = false
    
    //MARK - keyboard events
    override func keyDown(event: NSEvent) // A key is pressed
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
        } else if (event.keyCode == 2) {
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
        }
        
    }
    
    override func keyUp(event: NSEvent)
    {
        NSLog("keyUp")
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