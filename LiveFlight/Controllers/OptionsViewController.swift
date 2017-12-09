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
        
        self.logLocationLabel!.stringValue = UserDefaults.standard.string(forKey: "logPath") as! String
        
        
        /*
        
        // manual IP is deprecated
        
        self.manualIpToggle.state = Int(UserDefaults.standard.bool(forKey: "manualIP"))
        
        if UserDefaults.standard.string(forKey: "manualIPValue") != nil {
        
            self.manualIpValue!.stringValue = UserDefaults.standard.string(forKey: "manualIPValue") as! String
            
        }
        
        self.manualIpValue.delegate = self*/
        
    }
    
    @IBAction func selectLogFolder(sender:AnyObject) {
        
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: UserDefaults.standard.string(forKey: "logPath") as! String)
        
        /*
        
        // this doesn't work well with app sandboxing
        
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
                    UserDefaults.standard.set(folderPath, forKey: "logPath")
                    
                    self.showRestartPrompt()
                    
                }
                
            }
            
        }*/

    }
    
    @IBAction func resetSettings(sender: AnyObject) {
        
        for key in UserDefaults.standard.dictionaryRepresentation().keys {
            UserDefaults.standard.removeObject(forKey: key)
        }
        
        showRestartPrompt()
        
    }
    
    /*
    @IBAction func toggleManualIP(sender: AnyObject) {
        
        if manualIpToggle.state == 0 {
            //manualIpToggle.enabled = false
            UserDefaults.standard.set(false, forKey: "manualIP")
        } else if manualIpToggle.state == 1 {
            //manualIpToggle.enabled = true
            UserDefaults.standard.set(true, forKey: "manualIP")
        }
        
        showRestartPrompt()
        
    }
    */
    
    override func controlTextDidBeginEditing(_ obj: Notification) {
        
        // enter pressed, save new IP
        UserDefaults.standard.set(manualIpValue.stringValue, forKey: "manualIPValue")
        
    }
    
    func showRestartPrompt() {
        
        let alert = NSAlert()
        alert.messageText = "Changes saved!"
        alert.addButton(withTitle: "OK")
        alert.informativeText = "Restart LiveFlight Connect for the changes to take effect."
            
        alert.beginSheetModal(for: self.view.window!, completionHandler: { [unowned self] (returnCode) -> Void in
            
            NSLog("Restart prompt shown and closed.")
            
        })
        
    }
    
    
}
