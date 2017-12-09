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
        
        NotificationCenter.default.addObserver(self, selector: #selector(removeView(notification:)), name:NSNotification.Name(rawValue: "connectionStarted"), object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(presentUpdateView(notification:)), name:NSNotification.Name(rawValue: "updateAvailable"), object: nil)
        
    }
    
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @objc func removeView(notification: NSNotification) {
        
        // add observer for connection errors
        NotificationCenter.default.addObserver(self, selector: #selector(tcpError(notification:)), name:NSNotification.Name(rawValue: "tcpError"), object: nil)
        
        NSLog("Removing view...")
        DispatchQueue.main.sync {
            
            self.connectingView.isHidden = true
            if let ip = notification.userInfo!["ip"] as? String {
                self.ipLabel.stringValue = "Infinite Flight is at \(ip)" // this is passed in notification
            } else {
                self.ipLabel.stringValue = "Infinite Flight is connected, yet the connection seems unreliable"
            }
            
        }
        
    }
    
    @objc func tcpError(notification: NSNotification) {

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
                    if returnCode == NSApplication.ModalResponse.alertFirstButtonReturn {
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
        
        let forumURL = "https://help.liveflightapp.com/hc/en-us/articles/115003328053-Setup-Guide"
        NSWorkspace.shared.open(URL(string: forumURL)!)
        
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

