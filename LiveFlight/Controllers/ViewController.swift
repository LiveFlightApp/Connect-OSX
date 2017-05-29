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
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.removeView(notification:)), name:NSNotification.Name(rawValue: "connectionStarted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.presentUpdateView(notification:)), name:NSNotification.Name(rawValue: "updateAvailable"), object: nil)

        
    }
    
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func removeView(notification: NSNotification) {
        
        // add observer for connection errors
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.tcpError(notification:)), name:NSNotification.Name(rawValue: "tcpError"), object: nil)
        
        NSLog("Removing view...")
        DispatchQueue.main.sync {
            
            self.connectingView.isHidden = true
            self.ipLabel.stringValue = "Infinite Flight is at \(notification.userInfo!["ip"] as! String!)" // this is passed in notification
            
        }
        
    }
    
    func presentUpdateView(notification: NSNotification) {

        let log = UserDefaults.standard.value(forKey: "nextLog")
        let version = UserDefaults.standard.double(forKey: "nextVersion")
        
        let message = "Version \(version) is available:\n\nChangelog:\n\(log!)"
        
        let alert = NSAlert()
        alert.messageText = "An update is available"
        alert.addButton(withTitle: "Download Update")
        alert.informativeText = message
        
        alert.beginSheetModal(for: self.view.window!, completionHandler: { [unowned self] (returnCode) -> Void in
            if returnCode == NSAlertFirstButtonReturn {
                NSWorkspace.shared().open(NSURL(string: "http://connect.liveflightapp.com/update/mac")! as URL)
                NSApplication.shared().terminate(self)
            }
        })
        
    }
    
    func tcpError(notification: NSNotification) {

        // remove to stop duplicates
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "tcpError"), object: nil)
        
        DispatchQueue.main.sync {
        
            if self.alertIsShown == false {
            
                self.alertIsShown = true
                
                let alert = NSAlert()
                alert.messageText = "There was a problem"
                alert.addButton(withTitle: "OK")
                alert.informativeText = "LiveFlight Connect has lost connection to Infinite Flight.\n\nMake sure it is connected via the same network as this Mac. Try restarting Infinite Flight if issues persist."
                
                alert.beginSheetModal(for: self.view.window!, completionHandler: { [unowned self] (returnCode) -> Void in
                    if returnCode == NSAlertFirstButtonReturn {
                        
                        DispatchQueue.main.sync {
                            
                            self.connectingView.isHidden = false
                            
                        }
                        
                        self.alertIsShown = false
                        
                        if UserDefaults.standard.bool(forKey: "manualIP") != true {
                        
                            //start UDP listener
                            var receiver = UDPReceiver()
                            receiver = UDPReceiver()
                            receiver.startUDPListener()
                            
                        }
                        
                    }
                    
                })
                
            }
            
        }
        
    }


    
    @IBAction func openJoystickGuide(sender: AnyObject) {
        
        let forumURL = "http://help.liveflightapp.com/connect/setup-guide"
        NSWorkspace.shared().open(NSURL(string: forumURL)! as URL)
        
    }


}

extension NSView {
    
    var backgroundColor: NSColor? {
        get {
            if let colorRef = self.layer?.backgroundColor {
                return NSColor(cgColor: colorRef)
            } else {
                return nil
            }
        }
        set {
            self.wantsLayer = true
            self.layer?.backgroundColor = newValue?.cgColor
        }
    }
}

