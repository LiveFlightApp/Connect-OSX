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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeLabelValues:", name:"changeLabelValues", object: nil)
        
        //this is a hack, to avoid having to create a new NSNotification object
        NSNotificationCenter.defaultCenter().postNotificationName("changeLabelValues", object:nil)
        
    }
    
    func changeLabelValues(notification:NSNotification) {
        
        let pitch = NSUserDefaults.standardUserDefaults().integerForKey("pitch")
        let roll = NSUserDefaults.standardUserDefaults().integerForKey("roll")
        let throttle = NSUserDefaults.standardUserDefaults().integerForKey("throttle")
        let rudder = NSUserDefaults.standardUserDefaults().integerForKey("rudder")
        
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
        
    }
    
    /*
        Actions for setting axes
        ========================
    */
    
    @IBAction func pitch(sender: AnyObject) {
        
        NSNotificationCenter.defaultCenter().postNotificationName("tryPitch", object: nil)
        pitchLabel.stringValue = "Move the stick forwards and backwards"
        
    }
    
    @IBAction func roll(sender: AnyObject) {
        
        NSNotificationCenter.defaultCenter().postNotificationName("tryRoll", object: nil)
        rollLabel.stringValue = "Move the stick from side to side"
        
    }
    
    @IBAction func throttle(sender: AnyObject) {
        
        NSNotificationCenter.defaultCenter().postNotificationName("tryThrottle", object: nil)
        throttleLabel.stringValue = "Move the lever forwards and backwards"
        
    }
    
    @IBAction func rudder(sender: AnyObject) {
        
        NSNotificationCenter.defaultCenter().postNotificationName("tryRudder", object: nil)
        rudderLabel.stringValue = "Twist/move the rudder"
        
    }
    
    /*
        Actions for clearing saved axes
        ========================
    */
    
    @IBAction func clear(sender: AnyObject) {
        
        // remove saved axes
        NSUserDefaults.standardUserDefaults().setInteger(-2, forKey: "pitch")
        NSUserDefaults.standardUserDefaults().setInteger(-2, forKey: "roll")
        NSUserDefaults.standardUserDefaults().setInteger(-2, forKey: "throttle")
        NSUserDefaults.standardUserDefaults().setInteger(-2, forKey: "rudder")
        
        // update labels
        pitchLabel.stringValue = "No axis assigned"
        rollLabel.stringValue = "No axis assigned"
        throttleLabel.stringValue = "No axis assigned"
        rudderLabel.stringValue = "No axis assigned"
        
    }
    
    
}
