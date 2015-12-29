//
//  JoystickManager.m
//  LiveFlight
//
//  Created by Cameron Carmichael Alonso on 23/08/15.
//  Copyright (c) 2015 Cameron Carmichael Alonso. All rights reserved.
//

#import "JoystickManager.h"

@implementation JoystickManager

@synthesize joystickAddedDelegate;

static JoystickManager *instance;

- (id)init {
    self = [super init];
    
    if (self) {
        joysticks = [[NSMutableDictionary alloc] init];
        joystickIDIndex = 0;
        [self setupGamepads];
    }
    
    return self;
}

+ (void)initialize
{
    static BOOL initialized = NO;
    
    if (!initialized) {
        initialized = YES;
        instance = [[JoystickManager alloc] init];
    }
}

+ (JoystickManager *)sharedInstance {
    return instance;
}

- (unsigned long)connectedJoysticks {
    return [joysticks count];
}

- (int)deviceIDByReference:(IOHIDDeviceRef)deviceRef {
    for (id key in joysticks) {
        Joystick *thisJoystick = [joysticks objectForKey:key];
        
        if ([thisJoystick device] == deviceRef) {
            return [((NSNumber *)key) intValue];
        }
    }
    
    return -1;
}

- (Joystick *)joystickByID:(int)joystickID {
    return [joysticks objectForKey:[NSNumber numberWithInt:joystickID]];
}

- (void)registerNewJoystick:(Joystick *)joystick name:(NSString *)name id:(NSString *)id {
    [joysticks setObject:joystick forKey:[NSNumber numberWithInt:joystickIDIndex++]];
    NSLog(@"Gamepads registered: %lu", joysticks.count);

    [joystickAddedDelegate joystickAdded:joystick withName:name id:id];
}


void gamepadWasRemoved(void* inContext, IOReturn inResult, void* inSender, IOHIDDeviceRef device) {
    NSLog(@"Gamepad was unplugged");
}

void gamepadAction(void* inContext, IOReturn inResult, void* inSender, IOHIDValueRef value) {
    
    
    IOHIDElementRef element = IOHIDValueGetElement(value);
    IOHIDDeviceRef device = IOHIDElementGetDevice(element);

    int joystickID = [[JoystickManager sharedInstance] deviceIDByReference:device];
    
    if (joystickID == -1) {
        NSLog(@"Invalid device reported.");
        return;
    }

    Joystick *joystick = [[JoystickManager sharedInstance] joystickByID:joystickID];
    [joystick elementReportedChange:element];
    
}

void gamepadWasAdded(void* inContext, IOReturn inResult, void* inSender, IOHIDDeviceRef device) {
    IOHIDDeviceOpen(device, kIOHIDOptionsTypeNone);
    NSString *deviceName = [NSString stringWithFormat:@"%@ %@", (CFStringRef)IOHIDDeviceGetProperty(device, CFSTR(kIOHIDManufacturerKey)), (CFStringRef)IOHIDDeviceGetProperty(device, CFSTR(kIOHIDProductKey))];
    NSString *deviceID = [NSString stringWithFormat:@"%@", (CFStringRef)IOHIDDeviceGetProperty(device, CFSTR(kIOHIDProductIDKey))];
	IOHIDDeviceRegisterInputValueCallback(device, gamepadAction, inContext);
    
    Joystick *newJoystick = [[Joystick alloc] initWithDevice:device];
    [[JoystickManager sharedInstance] registerNewJoystick:newJoystick name:deviceName id:deviceID];

    NSLog(@"\nJoystick metadata:\n%@\n%@", deviceName, deviceID);
    
}


-(void)setupGamepads {
    hidManager = IOHIDManagerCreate( kCFAllocatorDefault, kIOHIDOptionsTypeNone);
    
    int usageKeys[] = { kHIDUsage_GD_GamePad,kHIDUsage_GD_Joystick,kHIDUsage_GD_MultiAxisController };
    
    int i;
    
    NSMutableArray *criterionSets = [NSMutableArray arrayWithCapacity:3];
    
    for (i=0; i<3; ++i) {
        int usageKeyConstant = usageKeys[i];
        NSMutableDictionary* criterion = [[NSMutableDictionary alloc] init];
        [criterion setObject: [NSNumber numberWithInt: kHIDPage_GenericDesktop] forKey: (NSString*)CFSTR(kIOHIDDeviceUsagePageKey)];
        [criterion setObject: [NSNumber numberWithInt: usageKeyConstant] forKey: (NSString*)CFSTR(kIOHIDDeviceUsageKey)];
        [criterionSets addObject:criterion];

    }
    
	IOHIDManagerSetDeviceMatchingMultiple(hidManager, (__bridge CFArrayRef)criterionSets);
    IOHIDManagerRegisterDeviceMatchingCallback(hidManager, gamepadWasAdded, (__bridge void*)self);
    IOHIDManagerRegisterDeviceRemovalCallback(hidManager, gamepadWasRemoved, (__bridge void*)self);
    IOHIDManagerScheduleWithRunLoop(hidManager, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    IOReturn tIOReturn = IOHIDManagerOpen(hidManager, kIOHIDOptionsTypeNone);
    (void)tIOReturn;
    
}


@end
