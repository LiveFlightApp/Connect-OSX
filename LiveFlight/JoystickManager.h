//
//  JoystickManager.h
//  LiveFlight
//
//  Created by Cameron Carmichael Alonso on 23/08/15.
//  Copyright (c) 2015 Cameron Carmichael Alonso. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOKit/hid/IOHIDLib.h>
#import "Joystick.h"

@interface JoystickManager : NSObject {
    
@private
    IOHIDManagerRef hidManager;
    
    NSMutableDictionary  *joysticks;
    
    int                 joystickIDIndex;
}

@property (assign) id joystickAddedDelegate;

+ (JoystickManager *)sharedInstance;
- (unsigned long)connectedJoysticks;
- (void)registerNewJoystick:(Joystick *)joystick;

- (int)deviceIDByReference:(IOHIDDeviceRef)deviceRef;
- (Joystick *)joystickByID:(int)joystickID;

@end
