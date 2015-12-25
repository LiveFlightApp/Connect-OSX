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
        
        pitchLabel.stringValue = "Axis " + String(NSUserDefaults.standardUserDefaults().integerForKey("pitch"))
        rollLabel.stringValue = "Axis " + String(NSUserDefaults.standardUserDefaults().integerForKey("roll"))
        rudderLabel.stringValue = "Axis " + String(NSUserDefaults.standardUserDefaults().integerForKey("rudder"))
        throttleLabel.stringValue = "Axis " + String(NSUserDefaults.standardUserDefaults().integerForKey("throttle"))
        
    }
    
    
    @IBAction func pitch(sender: AnyObject) {
        
        NSNotificationCenter.defaultCenter().postNotificationName("tryPitch", object: nil)
        pitchLabel.stringValue = "Move the axis around a bit..."
        
    }
    
    @IBAction func roll(sender: AnyObject) {
        
        NSNotificationCenter.defaultCenter().postNotificationName("tryRoll", object: nil)
        rollLabel.stringValue = "Move the axis around a bit..."
        
    }
    
    @IBAction func throttle(sender: AnyObject) {
        
        NSNotificationCenter.defaultCenter().postNotificationName("tryThrottle", object: nil)
        throttleLabel.stringValue = "Move the axis around a bit..."
        
    }
    
    @IBAction func rudder(sender: AnyObject) {
        
        NSNotificationCenter.defaultCenter().postNotificationName("tryRudder", object: nil)
        rudderLabel.stringValue = "Move the axis around a bit..."
        
    }
    
    
}
