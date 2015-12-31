//
//  OptionsViewController.swift
//  LiveFlight
//
//  Created by Cameron Carmichael Alonso on 31/12/2015.
//  Copyright © 2015 Cameron Carmichael Alonso. All rights reserved.
//

import Cocoa

class OptionsViewController: NSViewController, NSTextFieldDelegate {

    @IBOutlet weak var logLocationLabel:NSTextField!
    @IBOutlet weak var manualIpValue:NSTextField!
    @IBOutlet weak var manualIpToggle:NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.logLocationLabel!.stringValue = NSUserDefaults.standardUserDefaults().valueForKey("logPath") as! String
        self.manualIpToggle.state = Int(NSUserDefaults.standardUserDefaults().boolForKey("manualIP"))
        
        if NSUserDefaults.standardUserDefaults().valueForKey("manualIPValue") != nil {
        
            self.manualIpValue!.stringValue = NSUserDefaults.standardUserDefaults().valueForKey("manualIPValue") as! String
            
        }
        
        self.manualIpValue.delegate = self
        
    }
    
    @IBAction func selectLogFolder(sender:AnyObject) {
        
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.canChooseFiles = false
        
        panel.beginSheetModalForWindow(self.view.window!) { (result:Int) -> Void in
            
            if result == NSFileHandlingPanelOKButton {
                let urls = panel.URLs
                
                for url in urls {
                    
                    // remove file://
                    let folderPath = url.absoluteString.stringByReplacingOccurrencesOfString("file://", withString: "")
                    
                    self.logLocationLabel!.stringValue = folderPath
                    NSUserDefaults.standardUserDefaults().setValue(folderPath, forKey: "logPath")
                    
                    self.showRestartPrompt()
                    
                }
                
            }
            
        }

    }
    
    @IBAction func resetSettings(sender: AnyObject) {
        
        for key in NSUserDefaults.standardUserDefaults().dictionaryRepresentation().keys {
            NSUserDefaults.standardUserDefaults().removeObjectForKey(key)
        }
        
        showRestartPrompt()
        
    }
    
    //"manualIPValue"
    @IBAction func toggleManualIP(sender: AnyObject) {
        
        if manualIpToggle.state == 0 {
            //manualIpToggle.enabled = false
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "manualIP")
        } else if manualIpToggle.state == 1 {
            //manualIpToggle.enabled = true
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "manualIP")
        }
        
        showRestartPrompt()
        
    }
    
    override func controlTextDidEndEditing(obj: NSNotification) {
        
        // enter pressed, save new IP
        NSUserDefaults.standardUserDefaults().setValue(manualIpValue.stringValue, forKey: "manualIPValue")
        
    }
    
    func showRestartPrompt() {
        
        let alert = NSAlert()
        alert.messageText = "Changes saved!"
        alert.addButtonWithTitle("OK")
        alert.informativeText = "Restart LiveFlight Connect for the changes to take effect."
            
        alert.beginSheetModalForWindow(self.view.window!, completionHandler: { [unowned self] (returnCode) -> Void in
            
            NSLog("Restart prompt shown and closed.")
            
        })
        
    }
    
    
}
