//
//  ViewController.swift
//  LiveFlight
//
//  Created by Cameron Carmichael Alonso on 23/08/15.
//  Copyright (c) 2015 Cameron Carmichael Alonso. All rights reserved.
//

import Cocoa



class ViewController: NSViewController {
    
    @IBOutlet weak var connectingView:NSView!
    @IBOutlet var ipLabel:NSTextField!
    
    var alertIsShown = false
    
    var connector = InfiniteFlightAPIConnector()  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "removeView:", name:"connectionStarted", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "presentUpdateView:", name:"updateAvailable", object: nil)

        
    }
    
    
    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func removeView(notification: NSNotification) {
        
        // add observer for connection errors
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "tcpError:", name:"tcpError", object: nil)
        
        NSLog("Removing view...")
        dispatch_async(dispatch_get_main_queue(),{
            
            self.connectingView.hidden = true
            self.ipLabel.stringValue = "Infinite Flight is at \(notification.userInfo!["ip"] as! String!)" // this is passed in notification
            
        })
        
    }
    
    func presentUpdateView(notification: NSNotification) {

        let log = NSUserDefaults.standardUserDefaults().valueForKey("nextLog")
        let version = NSUserDefaults.standardUserDefaults().doubleForKey("nextVersion")
        
        let message = "Version \(version) is available:\n\nChangelog:\n\(log!)"
        
        let alert = NSAlert()
        alert.messageText = "An update is available"
        alert.addButtonWithTitle("Download Update")
        alert.informativeText = message
        
        alert.beginSheetModalForWindow(self.view.window!, completionHandler: { [unowned self] (returnCode) -> Void in
            if returnCode == NSAlertFirstButtonReturn {
                NSWorkspace.sharedWorkspace().openURL(NSURL(string: "http://connect.liveflightapp.com/update/mac")!)
                NSApplication.sharedApplication().terminate(self)
            }
        })
        
    }
    
    func tcpError(notification: NSNotification) {

        // remove to stop duplicates
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "tcpError", object: nil)
        
        dispatch_async(dispatch_get_main_queue(),{
        
            if self.alertIsShown == false {
            
                self.alertIsShown = true
                
                let alert = NSAlert()
                alert.messageText = "There was a problem"
                alert.addButtonWithTitle("OK")
                alert.informativeText = "LiveFlight Connect has lost connection to Infinite Flight.\n\nMake sure it is connected via the same network as this Mac. Try restarting Infinite Flight if issues persist."
                
                alert.beginSheetModalForWindow(self.view.window!, completionHandler: { [unowned self] (returnCode) -> Void in
                    if returnCode == NSAlertFirstButtonReturn {
                        dispatch_async(dispatch_get_main_queue(),{
                            
                            self.connectingView.hidden = false
                            
                        })
                        
                        self.alertIsShown = false
                        
                        if NSUserDefaults.standardUserDefaults().boolForKey("manualIP") != true {
                        
                            //start UDP listener
                            var receiver = UDPReceiver()
                            receiver = UDPReceiver()
                            receiver.startUDPListener()
                            
                        }
                    }
                })
                
            }
            
        })
        
    }


    
    @IBAction func openJoystickGuide(sender: AnyObject) {
        
        let forumURL = "http://help.liveflightapp.com/connect/setup-guide"
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: forumURL)!)
        
    }


}

extension NSView {
    
    var backgroundColor: NSColor? {
        get {
            if let colorRef = self.layer?.backgroundColor {
                return NSColor(CGColor: colorRef)
            } else {
                return nil
            }
        }
        set {
            self.wantsLayer = true
            self.layer?.backgroundColor = newValue?.CGColor
        }
    }
}

