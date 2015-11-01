//
//  CallParameter.m
//  LiveFlight
//
//  Created by Cameron Carmichael Alonso on 08/10/15.
//  Copyright © 2015 Cameron Carmichael Alonso. All rights reserved.
//

#import "CallParameter.h"

@implementation CallParameter
@synthesize name, value;

-(id) initWithName:(NSString*)nameVal value:(NSString*)valueVal {
    self = [super init];
    if(self) {
        name = nameVal;
        value = valueVal;
    }
    return self;
}


@end
