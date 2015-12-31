//
//  AppDelegate.swift
//  LiveFlight
//
//  Created by Cameron Carmichael Alonso on 23/08/15.
//  Copyright (c) 2015 Cameron Carmichael Alonso. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet var logButton: NSMenuItem!
    @IBOutlet var packetSpacingButton: NSMenuItem!
    var optionsWindow: NSWindowController!
    var reachability: Reachability?
    var receiver = UDPReceiver()
    var connector = InfiniteFlightAPIConnector()
    var joystickHelper = JoystickHelper()
    
    func applicationWillFinishLaunching(notification: NSNotification) {
        logAppInfo()
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        
        /*
            Check Networking Status
            ========================
        */
        
        do {
            reachability =  try Reachability(hostname: "http://www.liveflightapp.com/")
        } catch ReachabilityError.FailedToCreateWithAddress(_) {
            NSLog("Can't connect to LiveFlight")
            return
        } catch {}
        
        /*
            Load Settings
            ========================
        */
        
        if NSUserDefaults.standardUserDefaults().valueForKey("logPath") == nil { //NSURL(string: NSUserDefaults.standardUserDefaults().valueForKey("logPath") as! String) == nil {
            // not a valid url, set default to desktop
            
            if let dir : NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DesktopDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
             
                NSUserDefaults.standardUserDefaults().setValue(String(dir), forKey: "logPath")
                
            }
            
        }
        
        if NSUserDefaults.standardUserDefaults().boolForKey("logging") == true {
            
            //output to file
            let file = "liveflight_log.txt"
            
            if let dir : NSString = NSUserDefaults.standardUserDefaults().valueForKey("logPath") as! String {
                
                NSLog("Logging enabled to directory: %@", dir)
                
                let path = dir.stringByAppendingPathComponent(file);
                
                //remove old file
                do {
                    try NSFileManager.defaultManager().removeItemAtPath(path)
                }
                catch let error as NSError {
                    error.description
                }
                
                freopen(path.cStringUsingEncoding(NSASCIIStringEncoding)!, "a+", stderr)
                
            }
            
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "logging")
            logButton.state = 1;
            
        } else {
            
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "logging")
            logButton.state = 0;
        }
        
        
        //set delay button appropriately
        let currentDelay = NSUserDefaults.standardUserDefaults().integerForKey("packetDelay")
        let currentDelaySetup = NSUserDefaults.standardUserDefaults().boolForKey("packetDelaySetup")
        

        if currentDelaySetup == false {
            //set to 10ms as default
            NSUserDefaults.standardUserDefaults().setInteger(10, forKey: "packetDelay")
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "packetDelaySetup")
            packetSpacingButton.title = "Toggle Delay Between Packets (10ms)"
            
            //set all axes to -2
            NSUserDefaults.standardUserDefaults().setInteger(-2, forKey: "pitch")
            NSUserDefaults.standardUserDefaults().setInteger(-2, forKey: "roll")
            NSUserDefaults.standardUserDefaults().setInteger(-2, forKey: "throttle")
            NSUserDefaults.standardUserDefaults().setInteger(-2, forKey: "rudder")
            
            
        } else {
            packetSpacingButton.title = "Toggle Delay Between Packets (\(currentDelay)ms)"
            
        }
        
        
        /*
            Versioning
            ========================
        */
        
        let nsObject = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"]
        let bundleVersion = nsObject as! String
        
        if reachability?.isReachable() == true {

            NSLog("Checking versions...")
            
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
            
            
        } else {
            NSLog("Can't connect to the internet, sorry.")
        }
        
        NSLog("\n\n")
        
        
        /*
            Init Networking
            ========================
        */
        
        receiver = UDPReceiver()
        receiver.startUDPListener()

        
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    
    func logAppInfo() {
        
        let nsObject = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"]
        let bundleVersion = nsObject as! String
        NSLog("LiveFlight Connect version \(bundleVersion)")
        NSLog("OS: \(NSProcessInfo().operatingSystemVersionString)")
        NSLog("AppKit: \(NSAppKitVersionNumber)")
        NSLog("IFAddresses: \(getIFAddresses())")

        NSLog("\n\n")
    }
    
    
    /*
        Menu Settings
        ========================
    */
    
    @IBAction func openJoystickGuide(sender: AnyObject) {
        
        let forumURL = "https://community.infinite-flight.com/t/joysticks-on-ios-android-over-the-network-liveflight-connect/20017?u=carmalonso"
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: forumURL)!)
        
    }
    
    @IBAction func openGitHub(sender: AnyObject) {
        
        let githubURL = "https://github.com/LiveFlightApp/Connect-OSX"
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: githubURL)!)
        
    }
    
    @IBAction func openForum(sender: AnyObject) {
        
        let forumURL = "https://community.infinite-flight.com/?u=carmalonso"
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: forumURL)!)
        
    }
    
    @IBAction func openLiveFlight(sender: AnyObject) {
        
        let liveFlightURL = "http://www.liveflightapp.com"
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: liveFlightURL)!)
        
    }
    
    @IBAction func openLiveFlightFacebook(sender: AnyObject) {
        
        let liveFlightURL = "http://www.facebook.com/liveflightapp"
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: liveFlightURL)!)
        
    }
    
    @IBAction func openLiveFlightTwitter(sender: AnyObject) {
        
        let liveFlightURL = "http://www.twitter.com/liveflightapp"
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: liveFlightURL)!)
        
    }
    
    @IBAction func toggleLogging(sender: AnyObject) {
        //enable/disable logging
        
        if logButton.state == 0 {
            //enable
            logButton.state = 1
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "logging")
        } else {
            logButton.state = 0
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "logging")
        }
        
    }
    
    @IBAction func togglePacketSpacing(sender: AnyObject) {
        //change delay between sending packets
        //0, 10, 20, 50ms.
        
        let currentDelay = NSUserDefaults.standardUserDefaults().integerForKey("packetDelay")
        
        if currentDelay == 0 {
            //set to 10
            NSUserDefaults.standardUserDefaults().setInteger(10, forKey: "packetDelay")
            packetSpacingButton.title = "Toggle Delay Between Packets (10ms)"
            
        } else if currentDelay == 10 {
            //set to 20
            NSUserDefaults.standardUserDefaults().setInteger(20, forKey: "packetDelay")
            packetSpacingButton.title = "Toggle Delay Between Packets (20ms)"
            
        } else if currentDelay == 20 {
            //set to 50
            NSUserDefaults.standardUserDefaults().setInteger(50, forKey: "packetDelay")
            packetSpacingButton.title = "Toggle Delay Between Packets (50ms)"
            
        } else {
            //set to 0
            NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "packetDelay")
            packetSpacingButton.title = "Toggle Delay Between Packets (0ms)"
            
        }
        
    }
    
    @IBAction func openOptionsWindow(sender: AnyObject) {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        optionsWindow = storyboard.instantiateControllerWithIdentifier("optionsWindow") as! NSWindowController
        
        optionsWindow.showWindow(self)
        
    }
    
    func getIFAddresses() -> [String] {
        var addresses = [String]()
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs> = nil
        if getifaddrs(&ifaddr) == 0 {
            
            // For each interface ...
            for (var ptr = ifaddr; ptr != nil; ptr = ptr.memory.ifa_next) {
                let flags = Int32(ptr.memory.ifa_flags)
                var addr = ptr.memory.ifa_addr.memory
                
                // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
                if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                    if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                        
                        // Convert interface address to a human readable string:
                        var hostname = [CChar](count: Int(NI_MAXHOST), repeatedValue: 0)
                        if (getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),
                            nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                                if let address = String.fromCString(hostname) {
                                    addresses.append(address)
                                }
                        }
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        
        return addresses
    }
    
}


class WindowController: NSWindowController {
    
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
}


