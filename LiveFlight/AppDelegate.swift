//
//  AppDelegate.swift
//  LiveFlight
//
//  Created by Cameron Carmichael Alonso on 23/08/15.
//  Copyright (c) 2015 Cameron Carmichael Alonso. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, JoystickNotificationDelegate {

    @IBOutlet weak var window: NSWindow!
    var receiver = UDPReceiver()
    public var connector = InfiniteFlightAPIConnector()

    //joystick values
    var rollValue = 0;
    var pitchValue = 0;
    var rudderValue = 0;
    var throttleValue = 0;
    
    var tryPitch = false
    var tryRoll = false
    var tryThrottle = false
    var tryRudder = false
    

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        

        //output to file
        let file = "liveflight_log.txt"
        
        if let dir : NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DesktopDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
            let path = dir.stringByAppendingPathComponent(file);
            
            //remove old file
            do {
                try NSFileManager.defaultManager().removeItemAtPath(path)
            }
            catch let error as NSError {
                error.description
            }
            
            //freopen(path.cStringUsingEncoding(NSASCIIStringEncoding)!, "a+", stderr)
            
        }
        
        let nsObject = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"]
        let bundleVersion = nsObject as! String
        
        NSLog("LiveFlight Connect version \(bundleVersion)\n\n")
       
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "tryPitch:", name:"tryPitch", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "tryRoll:", name:"tryRoll", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "tryThrottle:", name:"tryThrottle", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "tryRudder:", name:"tryRudder", object: nil)
        
        
        //fetch versioning json
        let url = NSURL(string: "http://connect.liveflightapp.com/config/config.json")
        let request = NSURLRequest(URL: url!, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: 60)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
            
            do {
                if let response:NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers) as? Dictionary<String, AnyObject> {
                    
                    let results: NSArray = response["mac"] as! NSArray

                    //sort so highest version is at top
                    let descriptor: NSSortDescriptor = NSSortDescriptor(key: "version", ascending: false)
                    let sortedResults: NSArray = results.sortedArrayUsingDescriptors([descriptor])
                    
                    if let log = sortedResults[0]["log"] {
                        if let versionNumber = sortedResults[0]["version"] {
                            
                            
                            NSLog("Current version: \(bundleVersion)")
                            NSLog("Newest version: \(versionNumber!) - \(log!)")
                            
                            //compare this version number to bundle version
                            
                            NSUserDefaults.standardUserDefaults().setValue(log, forKey: "nextLog")
                            NSUserDefaults.standardUserDefaults().setDouble(Double(versionNumber as! NSNumber), forKey: "nextVersion")
                            
                            if (Double(versionNumber as! NSNumber) > Double(bundleVersion)) {
              
                                
                                //new version exists, present update dialog
                                NSLog("New version available!\n\n")
                                NSNotificationCenter.defaultCenter().postNotificationName("updateAvailable", object: sortedResults[0])
                                
                                
                            } else {
                                
                                NSLog("Up to date\n\n")
                                
                            }
                        }
                    }
                    
                } else {
                    NSLog("Failed to parse JSON")
                }
            } catch let serializationError as NSError {
                NSLog(String(serializationError))
            }
            
        }

        NSLog("\n\n")
        
        //setup joystick stuff
        let joystick:JoystickManager = JoystickManager.sharedInstance()
        joystick.joystickAddedDelegate = self;
        
        //start UDP listener
        receiver = UDPReceiver()
        receiver.startUDPListener()

        
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func tryPitch(notification: NSNotification) {
        tryPitch = true
    }
    
    func tryRoll(notification: NSNotification) {
        tryRoll = true
    }
    
    func tryThrottle(notification: NSNotification) {
        tryThrottle = true
    }
    
    func tryRudder(notification: NSNotification) {
        tryRudder = true
    }
    
    //joystick work
    func joystickAdded(joystick: Joystick!, withName name: String!) {
        joystick.registerForNotications(self)
        //device: IOHIDDeviceRef = joystick.device
        
        //joystickName.stringValue = name
    }
    
    func joystickStateChanged(joystick: Joystick!, axis:Int32) {
        
        NSLog("Axis changed: \(axis)")
        
        //check to see if calibrating
        if (tryPitch == true) {
            //detect axis then save
            NSUserDefaults.standardUserDefaults().setInteger(Int(axis), forKey: "pitch")
            tryPitch = false
            
            NSNotificationCenter.defaultCenter().postNotificationName("changeLabelValues", object:nil)
            
        } else if (tryRoll == true) {
            //detect axis then save
            NSUserDefaults.standardUserDefaults().setInteger(Int(axis), forKey: "roll")
            tryRoll = false
            
            NSNotificationCenter.defaultCenter().postNotificationName("changeLabelValues", object:nil)
            
        } else if (tryThrottle == true) {
            //detect axis then save
            NSUserDefaults.standardUserDefaults().setInteger(Int(axis), forKey: "throttle")
            tryThrottle = false
            
            NSNotificationCenter.defaultCenter().postNotificationName("changeLabelValues", object:nil)
            
        } else if (tryRudder == true) {
            //detect axis then save
            NSUserDefaults.standardUserDefaults().setInteger(Int(axis), forKey: "rudder")
            tryRudder = false
            
            NSNotificationCenter.defaultCenter().postNotificationName("changeLabelValues", object:nil)
            
        }
        
        let value:Int = Int(((joystick.getRelativeValueOfAxesIndex(axis) * 2) - 1) * 1024);
        
        if (Int(axis) == NSUserDefaults.standardUserDefaults().integerForKey("pitch")) {
            connector.didMoveAxis(0, value: Int32(value))
            
        } else if (Int(axis) == NSUserDefaults.standardUserDefaults().integerForKey("roll")) {
            connector.didMoveAxis(1, value: Int32(value))
            
        } else if (Int(axis) == NSUserDefaults.standardUserDefaults().integerForKey("throttle")) {
            connector.didMoveAxis(3, value: Int32(value))
            
        } else if (Int(axis) == NSUserDefaults.standardUserDefaults().integerForKey("rudder")) {
            connector.didMoveAxis(2, value: Int32(value))
            
        }
        
    }
    
    func joystickButtonReleased(buttonIndex: Int32, onJoystick joystick: Joystick!) {
        NSLog("Button --> Released \(buttonIndex)")
        connector.didPressButton(buttonIndex, state: 1)
        
    }
    
    func joystickButtonPushed(buttonIndex: Int32, onJoystick joystick: Joystick!) {
        
        NSLog("Button --> Pressed \(buttonIndex)")
        connector.didPressButton(buttonIndex, state: 0)
    }
    
}

class KeyboardListenerWindow: NSWindow {
    var connector = InfiniteFlightAPIConnector()
    var keydown = false
    
    //MARK - keyboard events
    override func keyDown(event: NSEvent) // A key is pressed
    {
        super.keyDown(event)
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


}


class WindowController: NSWindowController {
    
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
}


