//
//  OptionsViewController.swift
//  LiveFlight
//
//  Created by Cameron Carmichael Alonso on 31/12/2015.
//  Copyright © 2015 Cameron Carmichael Alonso. All rights reserved.
//

import Cocoa

class OptionsViewController: NSViewController {

    @IBOutlet weak var logLocationLabel:NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.logLocationLabel!.stringValue = NSUserDefaults.standardUserDefaults().valueForKey("logPath") as! String
        
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
