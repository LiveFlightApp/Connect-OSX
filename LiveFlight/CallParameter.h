//
//  CallParameter.h
//  LiveFlight
//
//  Created by Cameron Carmichael Alonso on 08/10/15.
//  Copyright © 2015 Cameron Carmichael Alonso. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CallParameter : NSObject {

    NSString *name;
    NSString *value;
    
    
}

-(id) initWithName:(NSString*)nameVal value:(NSString*)valueVal;

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *value;

@end
