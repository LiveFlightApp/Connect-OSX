//
//  JoystickHatswitch.h
//  LiveFlight
//
//  Created by Cameron Carmichael Alonso on 23/08/15.
//  Copyright (c) 2015 Cameron Carmichael Alonso. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOKit/hid/IOHIDLib.h>
#import "JoystickNotificationDelegate.h"

@interface JoystickHatswitch : NSObject  {
    IOHIDElementRef element;
    Joystick        *owner;
    
    int directions;
    BOOL buttonStates[4];
}

@property(readonly) IOHIDElementRef element;

-(id)initWithElement:(IOHIDElementRef)theElement andOwner:(Joystick *)theOwner;
- (void)checkValue:(int)value andDispatchButtonPressesWithIndexOffset:(int)offset toDelegate:(id<JoystickNotificationDelegate>)delegate;

@end
