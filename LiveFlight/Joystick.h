//
//  Joystick.h
//  LiveFlight
//
//  Created by Cameron Carmichael Alonso on 23/08/15.
//  Copyright (c) 2015 Cameron Carmichael Alonso. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOKit/hid/IOHIDLib.h>
#import "JoystickNotificationDelegate.h"

@interface Joystick : NSObject {
    IOHIDDeviceRef  device;
    NSArray *elements;
    NSArray *axes;
    NSArray *buttons;
    NSArray *hats;
    NSMutableArray *delegates;
}

@property(readwrite) IOHIDDeviceRef device;
@property(readonly) unsigned int numButtons;
@property(readonly) unsigned int numAxes;
@property(readonly) unsigned int numHats;

- (id)initWithDevice:(IOHIDDeviceRef)theDevice;
- (int)getElementIndex:(IOHIDElementRef)theElement;

- (double)getRelativeValueOfAxesIndex:(int)index;

- (void)elementReportedChange:(IOHIDElementRef)theElement;
- (void)registerForNotications:(id <JoystickNotificationDelegate>)delegate;
- (void)deregister:(id<JoystickNotificationDelegate>)delegate;

@end
