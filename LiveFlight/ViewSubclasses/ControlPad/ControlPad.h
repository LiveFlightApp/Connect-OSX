//
//  ControlPad.h
//  LiveFlight
//
//  Created by Cameron Carmichael Alonso on 17/10/15.
//  Copyright © 2015 Cameron Carmichael Alonso. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Connect-Swift.h"
#import "InfiniteFlightAPIConnector.h"


@interface ControlPad : NSView {
    NSTrackingArea * trackingArea;
    bool inArea;
    bool selected;
    int x;
    int y;
}

@end
