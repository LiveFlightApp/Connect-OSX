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
    @IBOutlet var gamepadModeButton: NSMenuItem!
    @IBOutlet var logButton: NSMenuItem!
    @IBOutlet var packetSpacingButton: NSMenuItem!
    var optionsWindow: NSWindowController!
    var reachability: Reachability?
    var receiver = UDPReceiver()
    @objc var connector = InfiniteFlightAPIConnector()
    var joystickHelper = JoystickHelper()
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        
        /*
            Load Settings
            ========================
        */

        
        // we always save to app sandbox
        if let dir : String = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first {
            
            let logDir = "\(dir)/Logs"
            UserDefaults.standard.set(String(logDir), forKey: "logPath")
            
        }
            

        if UserDefaults.standard.bool(forKey: "logging") == true {
            
            //output to file
            let file = "LiveFlight_Connect.log"
            
            if let dir : String = UserDefaults.standard.string(forKey: "logPath") {
                
                NSLog("Logging enabled to directory: %@", dir)
                
                let path = String(describing: URL(string: dir)!.appendingPathComponent(file));
                
                //remove old file
                do {
                    try FileManager.default.removeItem(atPath: path)
                }
                catch let error as NSError {
                    error.description
                }
                
                freopen(path.cString(using: String.Encoding.ascii)!, "a+", stderr)
                
            }
            
            UserDefaults.standard.set(true, forKey: "logging")
            logButton.state = NSControl.StateValue(rawValue: 1)
            
        } else {
            
            UserDefaults.standard.set(false, forKey: "logging")
            logButton.state = NSControl.StateValue(rawValue: 0)
        }
        
        // set gamepad mode toggle
        if UserDefaults.standard.bool(forKey: "gamepadMode") == true {
            
            gamepadModeButton.state = NSControl.StateValue(rawValue: 1)
            
        } else {
            
            gamepadModeButton.state = NSControl.StateValue(rawValue: 0)
            
        }
        

        //set delay button appropriately
        let currentDelay = UserDefaults.standard.integer(forKey: "packetDelay")
        let currentDelaySetup = UserDefaults.standard.bool(forKey: "packetDelaySetup")
        
        
        if currentDelaySetup == false {
            //set to 10ms as default
            UserDefaults.standard.set(10, forKey: "packetDelay")
            UserDefaults.standard.set(true, forKey: "packetDelaySetup")
            packetSpacingButton.title = "Toggle Delay Between Packets (10ms)"
            
            //set all axes to -2
            UserDefaults.standard.set(-2, forKey: "pitch")
            UserDefaults.standard.set(-2, forKey: "roll")
            UserDefaults.standard.set(-2, forKey: "throttle")
            UserDefaults.standard.set(-2, forKey: "rudder")
            
            
        } else {
            packetSpacingButton.title = "Toggle Delay Between Packets (\(currentDelay)ms)"
            
        }
        
        
        logAppInfo()
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        
        /*
            Check Networking Status
            ========================
        */
        
        do {
            reachability =  try Reachability(hostname: "http://www.liveflightapp.com/")
        } catch ReachabilityError.FailedToCreateWithAddress(_) {
            NSLog("Failed to create connection")
            return
        } catch {}
        
        
        #if RELEASE
        
            /*
                App Store Release
                ========================
            */
            Release().setupReleaseFrameworks()
            
        #endif


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
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    func logAppInfo() {
        
        let nsObject = Bundle.main.infoDictionary!["CFBundleShortVersionString"]
        let bundleVersion = nsObject as! String
        NSLog("LiveFlight Connect version \(bundleVersion)")
        NSLog("OS: \(ProcessInfo().operatingSystemVersionString)")
        NSLog("AppKit: \(NSAppKitVersion.current)")
        NSLog("IFAddresses: \(getIFAddresses())")

        NSLog("\n\n")
    }
    
    
    /*
        Menu Settings
        ========================
    */
    
    @IBAction func openJoystickGuide(sender: AnyObject) {
        
        let forumURL = "https://help.liveflightapp.com/hc/en-us/sections/115000759493-LiveFlight-Connect"
        NSWorkspace.shared.open(URL(string: forumURL)!)
        
    }
    
    @IBAction func openTerms(sender: AnyObject) {
        
        let forumURL = "https://help.liveflightapp.com/hc/en-us/articles/115003332994-Terms-of-Service"
        NSWorkspace.shared.open(URL(string: forumURL)!)
        
    }
    
    @IBAction func openPrivacyPolicy(sender: AnyObject) {
        
        let forumURL = "https://help.liveflightapp.com/hc/en-us/articles/115003327793-Privacy-Policy"
        NSWorkspace.shared.open(URL(string: forumURL)!)
        
    }
    
    @IBAction func openGitHub(sender: AnyObject) {
        
        let githubURL = "https://github.com/LiveFlightApp/Connect-OSX"
        NSWorkspace.shared.open(URL(string: githubURL)!)
        
    }
    
    @IBAction func openForum(sender: AnyObject) {
        
        let forumURL = "https://community.infinite-flight.com/"
       NSWorkspace.shared.open(URL(string: forumURL)!)
        
    }
    
    @IBAction func openLiveFlight(sender: AnyObject) {
        
        let liveFlightURL = "http://www.liveflightapp.com"
        NSWorkspace.shared.open(URL(string: liveFlightURL)!)
        
    }
    
    @IBAction func openLiveFlightFacebook(sender: AnyObject) {
        
        let liveFlightURL = "http://www.facebook.com/liveflightapp"
        NSWorkspace.shared.open(URL(string: liveFlightURL)!)
        
    }
    
    @IBAction func openLiveFlightTwitter(sender: AnyObject) {
        
        let liveFlightURL = "http://www.twitter.com/liveflightapp"
        NSWorkspace.shared.open(URL(string: liveFlightURL)!)
        
    }
    
    @IBAction func toggleGamepadMode(sender: AnyObject) {
        // enable/disable gamepad mode
        
        if gamepadModeButton.state.rawValue == 0 {
            //enable
            gamepadModeButton.state = NSControl.StateValue(rawValue: 1)
            UserDefaults.standard.set(true, forKey: "gamepadMode")
        } else {
            gamepadModeButton.state = NSControl.StateValue(rawValue: 0)
            UserDefaults.standard.set(false, forKey: "gamepadMode")
        }
        
    }
    
    @IBAction func toggleLogging(sender: AnyObject) {
        //enable/disable logging
        
        if logButton.state.rawValue == 0 {
            //enable
            logButton.state = NSControl.StateValue(rawValue: 1)
            UserDefaults.standard.set(true, forKey: "logging")
        } else {
            logButton.state = NSControl.StateValue(rawValue: 0)
            UserDefaults.standard.set(false, forKey: "logging")
        }
        
    }
    
    @IBAction func togglePacketSpacing(sender: AnyObject) {
        //change delay between sending packets
        //0, 10, 20, 50ms.
        
        let currentDelay = UserDefaults.standard.integer(forKey: "packetDelay")
        
        if currentDelay == 0 {
            //set to 10
            UserDefaults.standard.set(10, forKey: "packetDelay")
            packetSpacingButton.title = "Toggle Delay Between Packets (10ms)"
            
        } else if currentDelay == 10 {
            //set to 20
            UserDefaults.standard.set(20, forKey: "packetDelay")
            packetSpacingButton.title = "Toggle Delay Between Packets (20ms)"
            
        } else if currentDelay == 20 {
            //set to 50
            UserDefaults.standard.set(50, forKey: "packetDelay")
            packetSpacingButton.title = "Toggle Delay Between Packets (50ms)"
            
        } else {
            //set to 0
            UserDefaults.standard.set(0, forKey: "packetDelay")
            packetSpacingButton.title = "Toggle Delay Between Packets (0ms)"
            
        }
        
    }
    
    @IBAction func openOptionsWindow(sender: AnyObject) {
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        optionsWindow = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "optionsWindow")) as! NSWindowController
        
        optionsWindow.showWindow(self)
        
    }
    
    @IBAction func nextCamera(sender: AnyObject) {
        connector.nextCamera()
    }
    
    @IBAction func previousCamera(sender: AnyObject) {
        connector.previousCamera()
    }
    
    @IBAction func cockpitCamera(sender: AnyObject) {
        connector.cockpitCamera()
    }
    
    @IBAction func vcCamera(sender: AnyObject) {
        connector.vcCamera()
    }
    
    @IBAction func followCamera(sender: AnyObject) {
        connector.followCamera()
    }
    
    @IBAction func onBoardCamera(sender: AnyObject) {
        connector.onboardCamera()
    }
    
    @IBAction func flybyCamera(sender: AnyObject) {
        connector.flybyCamera()
    }
    
    @IBAction func towerCamera(sender: AnyObject) {
        connector.towerCamera()
    }
    
    @IBAction func landingGear(sender: AnyObject) {
        connector.landingGear()
    }
    
    @IBAction func spoilers(sender: AnyObject) {
        connector.spoilers()
    }
    
    @IBAction func flapsUp(sender: AnyObject) {
        connector.flapsUp()
    }
    
    @IBAction func flapsDown(sender: AnyObject) {
        connector.flapsDown()
    }
    
    @IBAction func brakes(sender: AnyObject) {
        connector.parkingBrakes()
    }
    
    @IBAction func autopilot(sender: AnyObject) {
        connector.autopilot()
    }
    
    @IBAction func pushback(sender: AnyObject) {
        connector.pushback()
    }
    
    @IBAction func pause(sender: AnyObject) {
        connector.togglePause()
    }
    
    @IBAction func landingLight(sender: AnyObject) {
        connector.landing()
    }
    
    @IBAction func strobeLight(sender: AnyObject) {
        connector.strobe()
    }
    
    @IBAction func beaconLight(sender: AnyObject) {
        connector.beacon()
    }
    
    @IBAction func navLight(sender: AnyObject) {
        connector.nav()
    }
    
    @IBAction func atcMenu(sender: AnyObject) {
        connector.atcMenu()
    }
    
    func getIFAddresses() -> [String] {
        /*var addresses = [String]()
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>? = nil
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
        }*/
        
        return []
    }
    
}


class WindowController: NSWindowController {
    
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
}


