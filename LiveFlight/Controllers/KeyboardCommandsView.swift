//
//  KeyboardCommandsView.swift
//  LiveFlight
//
//  Created by Cameron Carmichael Alonso on 26/12/2015.
//  Copyright © 2015 Cameron Carmichael Alonso. All rights reserved.
//

import Cocoa

class KeyboardCommandsView: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    @IBOutlet var tableView: NSTableView?
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        
    }
    
    func numberOfRowsInTableView(aTableView: NSTableView) -> Int
    {
        let numberOfRows:Int = getDataArray().count
        return numberOfRows
    }
    
    //set values
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        
        return getDataArray().objectAtIndex(row).objectForKey(tableColumn!.identifier)
        
    }
    
    
    
    func getDataArray () -> NSArray{
        let dataArray:[NSDictionary] =
            [
                ["Command": "Pitch Up", "Key": "Down Arrow"],
                ["Command": "Pitch Down", "Key": "Up Arrow"],
                ["Command": "Roll Left", "Key": "Left Arrow"],
                ["Command": "Roll Right", "Key": "Right Arrow"],
                ["Command": "Increase Throttle", "Key": "D"],
                ["Command": "Decrease Throttle", "Key": "C"],
                ["Command": "Landing Gear Toggle", "Key": "G"],
                ["Command": "Spoilers Toggle", "Key": "/"],
                ["Command": "Flaps Up", "Key": "["],
                ["Command": "Flaps Down", "Key": "]"],
                ["Command": "Previous Camera", "Key": "Q"],
                ["Command": "Next Camera", "Key": "E"],
                ["Command": "Parking Brakes", "Key":"."],
                ["Command": "Autopilot Toggle", "Key":"Z"],
                ["Command": "Pushback Toggle", "Key":"P"],
                ["Command": "Landing Light Toggle", "Key":"L"],
                ["Command": "Nav Light Toggle", "Key":"N"],
                ["Command": "Beacon Light Toggle", "Key":"B"],
                ["Command": "Strobe Toggle", "Key":"S"],
                //["Command": "Zoom In", "Key":"="], <- these two don't work yet properly
                //["Command": "Zoom Out", "Key":"-"],
                ["Command": "Pause Toggle", "Key":"␣ [Space]"],
                ["Command": "ATC Window Toggle", "Key":"A"],
                ["Command": "ATC Commands", "Key":"Numbers [1-0]"]
            ];

        return dataArray;
    }
    
}
