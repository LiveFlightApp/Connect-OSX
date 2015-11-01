//
//  Joystick.m
//  LiveFlight
//
//  Created by Cameron Carmichael Alonso on 23/08/15.
//  Copyright (c) 2015 Cameron Carmichael Alonso. All rights reserved.
//

#import "Joystick.h"
#import "JoystickHatswitch.h"

@implementation Joystick

@synthesize device;

- (id)initWithDevice:(IOHIDDeviceRef)theDevice
{
    self = [super init];
    if (self) {
        device = theDevice;
        
        delegates = [[NSMutableArray alloc] initWithCapacity:0];
        
        elements = (__bridge NSArray *)IOHIDDeviceCopyMatchingElements(theDevice, NULL, kIOHIDOptionsTypeNone);
        
        NSMutableArray *tempButtons = [NSMutableArray array];
        NSMutableArray *tempAxes = [NSMutableArray arrayWithCapacity:100];
        NSMutableArray *tempHats = [NSMutableArray array];
        
        for (int i = 0; i < 512; i++) {
            [tempAxes addObject:@""];
        }
        
        int i;
        for (i=0; i<elements.count; ++i) {
            IOHIDElementRef thisElement = (__bridge IOHIDElementRef)[elements objectAtIndex:i];
            
            int elementType = IOHIDElementGetType(thisElement);
            int elementUsage = IOHIDElementGetUsage(thisElement);
            
            if (elementUsage == kHIDUsage_GD_Hatswitch) {
                JoystickHatswitch *hatSwitch = [[JoystickHatswitch alloc] initWithElement:thisElement andOwner:self];
                [tempHats addObject:hatSwitch];
            } else if (elementType == kIOHIDElementTypeInput_Axis || elementType == kIOHIDElementTypeInput_Misc) {
                NSLog(@"Element: %@ Type: %d Usage: %d added at %lu", thisElement, elementType, elementUsage, (unsigned long)tempAxes.count);
                [tempAxes replaceObjectAtIndex:elementUsage withObject:(__bridge id)(thisElement)];
                //[tempAxes insertObject:(__bridge id)(thisElement) atIndex:elementUsage];
            } else if (elementType == kIOHIDElementTypeInput_Button) {
                [tempButtons addObject:(__bridge id)(thisElement)];
            } else {

            }

            
        }
        buttons = [NSArray arrayWithArray:tempButtons];
        axes = [NSArray arrayWithArray:tempAxes];
        hats = [NSArray arrayWithArray:tempHats];
        
        NSLog(@"New device address: %p from %p",device,theDevice);
        NSLog(@"found %lu buttons, %lu axes and %lu hats",tempButtons.count,tempAxes.count,tempHats.count);
        // For more detailed info there are Usage tables
        // eg: kHIDUsage_GD_X
        // declared in IOHIDUsageTables.h
        // could use to determine major axes
    }
    
    return self;
}

- (void)elementReportedChange:(IOHIDElementRef)theElement {
    
    int elementType = IOHIDElementGetType(theElement);
    IOHIDValueRef pValue;
    IOHIDDeviceGetValue(device, theElement, &pValue);
    
    int elementUsage = IOHIDElementGetUsage(theElement);
    long value = IOHIDValueGetIntegerValue(pValue);
    int i;
    
    if (elementUsage == kHIDUsage_GD_Hatswitch) {
        
        // determine a unique offset. index is buttons.count
        // so all dpads will report buttons.count+(hats.indexOfObject(hatObject)*5)
        // 8 ways are interpreted as UP DOWN LEFT RIGHT so this is fine.
        int offset = (int)[buttons count];
        JoystickHatswitch *hatswitch;
        for (i=0; i<hats.count; ++i) {
            hatswitch = [hats objectAtIndex:i];
            
            if ([hatswitch element] == theElement) {
                offset += i*5;
                break;
            }
        }
        
        for (i=0; i<delegates.count; ++i) {
            id <JoystickNotificationDelegate> delegate = [delegates objectAtIndex:i];
            [hatswitch checkValue:value andDispatchButtonPressesWithIndexOffset:offset toDelegate:delegate];
        }
        
        return;
    }
    
    
    if (elementType != kIOHIDElementTypeInput_Axis && elementType != kIOHIDElementTypeInput_Misc) {
        
        
        for (i=0; i<delegates.count; ++i) {
            id <JoystickNotificationDelegate> delegate = [delegates objectAtIndex:i];
            
            if (value==1)
                [delegate joystickButtonPushed:[self getElementIndex:theElement] onJoystick:self];
            else
                [delegate joystickButtonReleased:[self getElementIndex:theElement] onJoystick:self];
                 
        }
        
        NSLog(@"Non-axis reported value of %ld",value);
        return;
    }
    
    
    NSLog(@"Axis %d reported value of %ld", elementUsage,value);
    
    
    for (i=0; i<delegates.count; ++i) {
        id <JoystickNotificationDelegate> delegate = [delegates objectAtIndex:i];
        
        [delegate joystickStateChanged:self axis:elementUsage];
    }
}

- (void)registerForNotications:(id <JoystickNotificationDelegate>)delegate {
    [delegates addObject:delegate];
}

- (void)deregister:(id<JoystickNotificationDelegate>)delegate {
    [delegates removeObject:delegate];
}

- (int)getElementIndex:(IOHIDElementRef)theElement {
    int elementType = IOHIDElementGetType(theElement);
    
    NSArray *searchArray;
    NSString *returnString = @"";
    
    if (elementType == kIOHIDElementTypeInput_Button) {
        searchArray = buttons;
        returnString = @"Button";
    } else {
        searchArray = axes;
        returnString = @"Axis";
    }
    
    int i;
    
    for (i=0; i<searchArray.count; ++i) {
        if ([searchArray objectAtIndex:i] == (__bridge id)(theElement))
            return i;
            //  returnString = [NSString stringWithFormat:@"%@_%d",returnString,i];
    }
    
    return -1;
}

- (double)getRelativeValueOfAxesIndex:(int)index {
    
    NSLog(@"Axis: %d", index);
    
    if (![[axes objectAtIndex:index] isEqual:@""]) {
        
        IOHIDElementRef theElement = (__bridge IOHIDElementRef)([axes objectAtIndex:index]);
        
        double value;
        double min = IOHIDElementGetPhysicalMin(theElement);
        double max = IOHIDElementGetPhysicalMax(theElement);
        
        IOHIDValueRef pValue;
        IOHIDDeviceGetValue(device, theElement, &pValue);
        
        value = ((double)IOHIDValueGetIntegerValue(pValue)-min) * (1/(max-min));
        
        return value;
            
    } else {
        return 0;
    }
}

- (unsigned int)numButtons {
    return (unsigned int)[buttons count];
}

- (unsigned int)numAxes {
    return (unsigned int)[axes count];
}

- (unsigned int)numHats {
    return (unsigned int)[hats count];
}



@end
