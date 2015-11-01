//
//  APICall.m
//  Infinite Flight Live
//
//  Created by Cameron Carmichael Alonso on 21/03/2015.
//  Copyright (c) 2015 Cameron Carmichael Alonso. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APICall.h"

@implementation APICall
@synthesize command, param;

-(id) initWithCommand:(NSString*)commandVal value:(CallParameter*)valueVal {
    self = [super init];
    if(self) {
        command = commandVal;
        param = valueVal;
    }
    return self;
}

@end
