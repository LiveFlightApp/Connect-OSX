//
//  JoystickViewController.swift
//  LiveFlight
//
//  Created by Cameron Carmichael Alonso on 11/10/15.
//  Copyright © 2015 Cameron Carmichael Alonso. All rights reserved.
//

import Cocoa

class JoystickViewController: NSViewController {
    
    @IBOutlet weak var pitchLabel: NSTextField!
    @IBOutlet weak var rollLabel: NSTextField!
    @IBOutlet weak var throttleLabel: NSTextField!
    @IBOutlet weak var rudderLabel: NSTextField!
    @IBOutlet weak var joystickName: NSTextField!
    @IBOutlet weak var joystickRecognised: NSTextField!
    @IBOutlet var allClearView: Status!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(JoystickViewController.changeLabelValues(notification:)), name:NSNotification.Name(rawValue: "changeLabelValues"), object: nil)
        
        //this is a hack, to avoid having to create a new NSNotification object
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeLabelValues"), object:nil)
        
    }
    
    func changeLabelValues(notification:NSNotification) {
        
        allClearView!.isHidden = true
        
        let pitch = UserDefaults.standard.integer(forKey: "pitch")
        let roll = UserDefaults.standard.integer(forKey: "roll")
        let throttle = UserDefaults.standard.integer(forKey: "throttle")
        let rudder = UserDefaults.standard.integer(forKey: "rudder")
        
        if pitch != -2 {
            pitchLabel.stringValue = "Axis \(String(pitch))"
        }
        
        if roll != -2 {
            rollLabel.stringValue = "Axis \(String(roll))"
        }
        
        if throttle != -2 {
            throttleLabel.stringValue = "Axis \(String(throttle))"
        }
        
        if rudder != -2 {
            rudderLabel.stringValue = "Axis \(String(rudder))"
        }
        

        if joystickConfig.joystickConnected == true {
            
            // remove duplicate words from name
            // some manufacturers include name in product name too
            var joystickNameArray = joystickConfig.connectedJoystickName.characters.split{$0 == " "}.map(String.init)
            
            var filter = Dictionary<String,Int>()
            var len = joystickNameArray.count
            for index in 0..<len {
                let value = joystickNameArray[index]
                if (filter[value] != nil) {
                    joystickNameArray.remove(at: (index - 1))
                    len -= 1
                }else{
                    filter[value] = 1
                }
            }
            
            joystickName.stringValue = joystickNameArray.joined(separator: " ")
            
            let mapStatus = UserDefaults.standard.integer(forKey: "mapStatus")
            
            if mapStatus == -2 {
                joystickRecognised.stringValue = "Using custom-assigned values for axes."
                
                
            } else if mapStatus == 0 {
                joystickRecognised.stringValue = "Using generic joystick values. These may not work correctly."
                
            } else if mapStatus == 1 {
                joystickRecognised.stringValue = "Using accurate values for your joystick (provided by LiveFlight)."
                
                allClearView!.isHidden = false
                
            } else {
                joystickRecognised.stringValue = "Using generic joystick values. These may not work correctly."
                
            }
            
            
        } else {
            joystickName.stringValue = "No joystick connected"
            joystickRecognised.stringValue = "Plug a joystick in via USB to get started."
        }
    }
    
    /*
        Actions for setting axes
        ========================
    */
    
    @IBAction func pitch(sender: AnyObject) {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "tryPitch"), object: nil)
        pitchLabel.stringValue = "Move the stick forwards and backwards"
        
        UserDefaults.standard.set(-2, forKey: "mapStatus")
        
    }
    
    @IBAction func roll(sender: AnyObject) {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "tryRoll"), object: nil)
        rollLabel.stringValue = "Move the stick from side to side"
        
        UserDefaults.standard.set(-2, forKey: "mapStatus")
        
    }
    
    @IBAction func throttle(sender: AnyObject) {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "tryThrottle"), object: nil)
        throttleLabel.stringValue = "Move the lever forwards and backwards"
        
        UserDefaults.standard.set(-2, forKey: "mapStatus")
        
    }
    
    @IBAction func rudder(sender: AnyObject) {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "tryRudder"), object: nil)
        rudderLabel.stringValue = "Twist/move the rudder"
        
        UserDefaults.standard.set(-2, forKey: "mapStatus")
        
    }
    
    /*
        Actions for clearing saved axes
        ========================
    */
    
    @IBAction func clear(sender: AnyObject) {
        
        // remove saved axes
        UserDefaults.standard.set(-2, forKey: "pitch")
        UserDefaults.standard.set(-2, forKey: "roll")
        UserDefaults.standard.set(-2, forKey: "throttle")
        UserDefaults.standard.set(-2, forKey: "rudder")
        UserDefaults.standard.set(-2, forKey: "mapStatus")
        
        // update labels
        pitchLabel.stringValue = "No axis assigned"
        rollLabel.stringValue = "No axis assigned"
        throttleLabel.stringValue = "No axis assigned"
        rudderLabel.stringValue = "No axis assigned"
        
    }
    
    
}
