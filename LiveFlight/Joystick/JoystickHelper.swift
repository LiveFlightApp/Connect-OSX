//
//  JoystickHelper.swift
//  LiveFlight
//
//  Created by Cameron Carmichael Alonso on 29/12/2015.
//  Copyright © 2015 Cameron Carmichael Alonso. All rights reserved.
//

import Cocoa

class JoystickConfig {
    var joystickConnected:Bool = false
    var connectedJoystickName:String = ""
    init(connected:Bool, name:String) {
        self.joystickConnected = connected
        self.connectedJoystickName = name
    }
}

var joystickConfig = JoystickConfig(connected: false, name: "")

class JoystickHelper: NSObject, JoystickNotificationDelegate {

    let connector = InfiniteFlightAPIConnector()
    let controls = FlightControls()
    
    //joystick values
    var rollValue = 0;
    var pitchValue = 0;
    var rudderValue = 0;
    var throttleValue = 0;
    
    var tryPitch = false
    var tryRoll = false
    var tryThrottle = false
    var tryRudder = false
    
    override init() {
        super.init()
        
        /*
            Init Joystick Manager
            ========================
        */
        
        let joystick:JoystickManager = JoystickManager.sharedInstance()
        joystick.joystickAddedDelegate = self;
        
        
        /*
            NotificationCenter setup
            ========================
        */
        
        NotificationCenter.default.addObserver(self, selector: #selector(JoystickHelper.setTryPitch(notification:)), name:NSNotification.Name(rawValue: "tryPitch"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(JoystickHelper.setTryRoll(notification:)), name:NSNotification.Name(rawValue: "tryRoll"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(JoystickHelper.setTryThrottle(notification:)), name:NSNotification.Name(rawValue: "tryThrottle"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(JoystickHelper.setTryRudder(notification:)), name:NSNotification.Name(rawValue: "tryRudder"), object: nil)

        
    }
    
    func setTryPitch(notification: NSNotification) {
        tryPitch = true
    }
    
    func setTryRoll(notification: NSNotification) {
        tryRoll = true
    }
    
    func setTryThrottle(notification: NSNotification) {
        tryThrottle = true
    }
    
    func setTryRudder(notification: NSNotification) {
        tryRudder = true
    }
    
    //joystick work
    func joystickAdded(_ joystick: Joystick!) {
        joystick.register(forNotications: self)
        
        if UserDefaults.standard.integer(forKey: "lastJoystick") != Int(joystick.productId) {
            // different joystick. Reset
         
            // remove last map
            UserDefaults.standard.removeObject(forKey: "mapStatus")
            
            // set axesSet to false
            UserDefaults.standard.set(false, forKey: "axesSet")
            
        }
        
        
        // set last joystick name and connected
        joystickConfig = JoystickConfig(connected: true, name: ("\(joystick.manufacturerName) \(joystick.productName)"))
        
        
        let axesSet = UserDefaults.standard.bool(forKey: "axesSet")
        
        // this is to reset axes when upgrading. Since there is a common pattern, there shouldn't be much impact.
        let axesSet11 = UserDefaults.standard.bool(forKey: "axesSet11")
        
        if axesSet != true || axesSet11 != true {
            // axes haven't been set yet
            
            // check to see if json exists with joystick name
            guard let path = Bundle.main.path(forResource: "JoystickMapping/\(joystick.manufacturerName) \(joystick.productName)", ofType: "json") else {
                
                // No map found
                NSLog("No map found - setting default values...")
                
                // Default values
                UserDefaults.standard.set(49, forKey: "pitch")
                UserDefaults.standard.set(48, forKey: "roll")
                UserDefaults.standard.set(50, forKey: "throttle")
                UserDefaults.standard.set(53, forKey: "rudder")
                
                // using generic values
                UserDefaults.standard.set(0, forKey: "mapStatus")
                
                return
            }
            
            // if this point is reached, a map exists
            let fileData = NSData(contentsOfFile: path)
            
            do {
                if let response:NSDictionary = try JSONSerialization.jsonObject(with: fileData! as Data, options:JSONSerialization.ReadingOptions.mutableContainers) as? Dictionary<String, AnyObject> as! NSDictionary {
                    
                    let pitchAxis = response.value(forKey: "Pitch-OSX") as! Int
                    let rollAxis = response.value(forKey: "Roll-OSX") as! Int
                    let throttleAxis = response.value(forKey: "Throttle-OSX") as! Int
                    let rudderAxis = response.value(forKey: "Rudder-OSX") as! Int
                    
                    //save values
                    UserDefaults.standard.set(pitchAxis, forKey: "pitch")
                    UserDefaults.standard.set(rollAxis, forKey: "roll")
                    UserDefaults.standard.set(throttleAxis, forKey: "throttle")
                    UserDefaults.standard.set(rudderAxis, forKey: "rudder")
                    
                    // using mapped values
                    UserDefaults.standard.set(1, forKey: "mapStatus")
                    
                } else {
                    NSLog("Failed to parse JSON")
                }
            } catch let serializationError as NSError {
                NSLog(String(describing: serializationError))
            }
            
        }
        
        // change labels and mark as axes set
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeLabelValues"), object:nil)
        UserDefaults.standard.set(true, forKey: "axesSet")
        UserDefaults.standard.set(true, forKey: "axesSet11")
        
        UserDefaults.standard.set(Int(joystick.productId), forKey: "lastJoystick")
        
    }
    
    func joystickRemoved(_ joystick: Joystick!) {
        
        joystickConfig = JoystickConfig(connected: false, name: "")
        

        // change label values
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeLabelValues"), object:nil)
        
    }
    
    func joystickStateChanged(_ joystick: Joystick!, axis:Int32) {
  
        //check to see if calibrating
        if (tryPitch == true) {
            //detect axis then save
            UserDefaults.standard.set(Int(axis), forKey: "pitch")
            tryPitch = false
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeLabelValues"), object:nil)
            
        } else if (tryRoll == true) {
            //detect axis then save
            UserDefaults.standard.set(Int(axis), forKey: "roll")
            tryRoll = false
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeLabelValues"), object:nil)
            
        } else if (tryThrottle == true) {
            //detect axis then save
            UserDefaults.standard.set(Int(axis), forKey: "throttle")
            tryThrottle = false
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeLabelValues"), object:nil)
            
        } else if (tryRudder == true) {
            //detect axis then save
            UserDefaults.standard.set(Int(axis), forKey: "rudder")
            tryRudder = false
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeLabelValues"), object:nil)
            
        }
        
        
        var value:Int32 = 0
        
        // print relVal - this is useful for debugging
        let relVal = joystick.getRelativeValue(ofAxesIndex: axis)
        NSLog("RelVal: \(relVal)")
        
        if UserDefaults.standard.bool(forKey: "gamepadMode") == true {
        
            // is a gamepad
            // values are [-128, 128]
            
             value = Int32(joystick.getRelativeValue(ofAxesIndex: axis) * 2048)
            
        } else {
            
            // raw values are [0, 1024]
            value = Int32(((joystick.getRelativeValue(ofAxesIndex: axis) * 2) - 1) * 1024)

        }
        
        if (Int(axis) == UserDefaults.standard.integer(forKey: "pitch")) {
            controls.pitchChanged(value: value)
            
        } else if (Int(axis) == UserDefaults.standard.integer(forKey: "roll")) {
            controls.rollChanged(value: value)
            
        } else if (Int(axis) == UserDefaults.standard.integer(forKey: "throttle")) {
            controls.throttleChanged(value: value)
            
        } else if (Int(axis) == UserDefaults.standard.integer(forKey: "rudder")) {
            controls.rudderChanged(value: value)
            
        }
        
    }
    
    func joystickButtonReleased(_ buttonIndex: Int32, on joystick: Joystick!) {
        NSLog("Button --> Released \(buttonIndex)")
        connector.didPressButton(buttonIndex, state: 1)
        
    }
    
    func joystickButtonPushed(_ buttonIndex: Int32, on joystick: Joystick!) {
        
        NSLog("Button --> Pressed \(buttonIndex)")
        connector.didPressButton(buttonIndex, state: 0)
    }
    
}
