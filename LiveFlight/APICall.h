//
//  APICall.h
//  Infinite Flight Live
//
//  Created by Cameron Carmichael Alonso on 21/03/2015.
//  Copyright (c) 2015 Cameron Carmichael Alonso. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CallParameter.h"

@interface APICall : NSObject {
    
    NSString *command;
    
}

@property (nonatomic, retain) NSString *command;
@property (nonatomic, assign) CallParameter *param;



@end
