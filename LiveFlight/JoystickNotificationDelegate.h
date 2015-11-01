//
//  JoystickNotificationDelegate.h
//  LiveFlight
//
//  Created by Cameron Carmichael Alonso on 23/08/15.
//  Copyright (c) 2015 Cameron Carmichael Alonso. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Joystick;

@protocol JoystickNotificationDelegate

- (void)joystickAdded:(Joystick*)joystick withName:(NSString *)name;
- (void)joystickStateChanged:(Joystick*)joystick axis:(int)axis;
- (void)joystickButtonPushed:(int)buttonIndex onJoystick:(Joystick*)joystick;
- (void)joystickButtonReleased:(int)buttonIndex onJoystick:(Joystick*)joystick;

@end
