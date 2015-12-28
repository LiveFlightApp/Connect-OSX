//
//  InfiniteFlightAPIConnector.m
//  LiveFlight
//
//  Created by Cameron Carmichael Alonso on 03/09/15.
//  Copyright (c) 2015 Cameron Carmichael Alonso. All rights reserved.
//

#import "InfiniteFlightAPIConnector.h"

CFReadStreamRef readStream;
CFWriteStreamRef writeStream;

NSInputStream *inputStream;
NSOutputStream *outputStream;

@implementation InfiniteFlightAPIConnector

- (void)connectToInfiniteFlightWithIP:(NSString *)ip {
    
    port = 10111;
    NSURL *url = [NSURL URLWithString:ip];
    
    NSLog(@"Setting up connection to %@ : %i", [url absoluteString], port);
    
    CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (__bridge CFStringRef)ip, port, &readStream, &writeStream);
    
    if(!CFWriteStreamOpen(writeStream)) {
        NSLog(@"Error, writeStream not open");
        
        return;
    }
    [self open];
    
    NSLog(@"Status of outputStream: %lu", (unsigned long)[outputStream streamStatus]);
    
    lastSend = [NSDate date];
    
    //send notification to hide loading view
    [[NSNotificationCenter defaultCenter] postNotificationName:@"connectionStarted" object:nil];
    
    return;
    
}

#pragma mark NSStream delegate

- (void)open {
    NSLog(@"Opening streams.");
    
    inputStream = (__bridge NSInputStream *)readStream;
    outputStream = (__bridge NSOutputStream *)writeStream;

    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [inputStream open];
    [outputStream open];
}

- (void)close {
    NSLog(@"Closing streams.");
    
    [inputStream close];
    [outputStream close];
    
    [inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [inputStream setDelegate:nil];
    [outputStream setDelegate:nil];

    inputStream = nil;
    outputStream = nil;
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)event {
    NSLog(@"Stream triggered.");
    
    switch(event) {
        case NSStreamEventHasSpaceAvailable: {
            if(stream == outputStream) {
                NSLog(@"outputStream is ready.");
            }
            break;
        }
        case NSStreamEventHasBytesAvailable: {
            if(stream == inputStream) {
                NSLog(@"inputStream is ready.");
                
                uint8_t buf[1024];
                unsigned int len = 0;
                
                len = [inputStream read:buf maxLength:1024];
                
                if(len > 0) {
                    NSMutableData* data=[[NSMutableData alloc] initWithLength:0];
                    
                    [data appendBytes: (const void *)buf length:len];
                    
                    NSString *s = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                    
                    [self readIn:s];
                    
                }
            }
            break;
        }
        case NSStreamEventErrorOccurred: {
            NSLog(@"A stream error occurred");
            break;
        }
        case NSStreamEventEndEncountered: {
            NSLog(@"Stream end encountered");
            break;
        }
        case NSStreamEventOpenCompleted: {
            NSLog(@"Stream successfully opened");
            break;
        }
        case NSStreamEventNone: {
            break;
        }
    }
}


- (void)readIn:(NSString *)s {
    NSLog(@"Reading: %@", s);
}

-(void)sendWithString:(NSString *)string params:(NSArray *)params isJoystick:(BOOL)isJoystick {
    
    if (params == nil) {
        params = [NSArray array];
    }
    
    NSData *arrayData = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    NSString *arrayString = [[NSString alloc] initWithData:arrayData encoding:NSUTF8StringEncoding];
    
    string = [NSString stringWithFormat:@"{\"Command\":\"%@\",\"Parameters\":%@}\n", string, arrayString];
    NSLog(@"Command: %@", string);
    
    NSData *            stringData;
    NSUInteger          stringLength;
    union {
        uint32_t    u32;
        uint8_t     u8s[4];
    } lengthConverter;
    
    NSMutableData *     result;
    __Check_Compile_Time(sizeof(lengthConverter) == 4);
    
    stringData = [string dataUsingEncoding:NSUTF8StringEncoding];
    stringLength = stringData.length;
    assert(stringLength < ((NSUInteger) 1 * 1024 * 1024 * 1024));   // 1 GiB
    lengthConverter.u32 = OSSwapHostToLittleInt32(stringLength);
    
    result = [[NSMutableData alloc] init];
    [result appendBytes:&lengthConverter.u8s length:sizeof(lengthConverter.u8s)];
    [result appendData:stringData];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //calculate time since last packet sent
        double timePassed = [lastSend timeIntervalSinceNow] * -1000.0;
        double timeToPass = [[NSUserDefaults standardUserDefaults] integerForKey:@"packetDelay"];
        
        //check if is joystick command
        if (isJoystick == true) {
            //joystick command - time check enabled
            
            if (timePassed > timeToPass) {
                
                //been longer than 20ms, send with less risk of overloading server
                [self writeResult:result];
                
            } else {
                NSLog(@"Ignoring packet, too soon since previous...");
            }
                
        } else {
            //standard button, time check disabled
            [self writeResult:result];
        }
        
        lastSend = [NSDate date];
        
    });

}

-(void)writeResult:(NSMutableData *)result {
    
    NSInteger sent = [outputStream write:result.bytes maxLength:result.length];
    NSLog(@"Write result: %ld", (long)sent);
    if (sent == -1) {
        //error. probably disconnected
        [[NSNotificationCenter defaultCenter] postNotificationName:@"tcpError" object:nil];
    }
    
}


#pragma mark joystick actions
-(void)didMoveAxis:(int)axis value:(int)value {
    
    NSString *param = [NSString stringWithFormat:@"{\"Name\":\"%d\",\"Value\":\"%d\"}", axis, value];
    
    NSData *data = [param dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    NSArray *params = [NSArray arrayWithObjects:json, nil];
    
    [self sendWithString:@"NetworkJoystick.SetAxisValue" params:params isJoystick:true];
    
}

-(void)didPressButton:(int)button state:(int)state {
    
    NSString *stateString;
    if (state != 0) {
        stateString = @"Up";
    } else {
        stateString = @"Down";
    }
    
    NSString *param = [NSString stringWithFormat:@"{\"Name\":\"%d\",\"Value\":\"%@\"}", button, stateString];
    NSData *data = [param dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    NSArray *params = [NSArray arrayWithObjects:json, nil];
    
    [self sendWithString:@"NetworkJoystick.SetButtonState" params:params isJoystick:false];
    
    
}

#pragma mark commands

/*
     Cameras
     ========================
*/

-(void)previousCamera {
    [self sendWithString:@"Commands.PrevCamera" params:nil isJoystick:false];
}

-(void)nextCamera {
    [self sendWithString:@"Commands.NextCamera" params:nil isJoystick:false];
}

-(void)cockpitCamera {
    [self sendWithString:@"Commands.SetCockpitCamera" params:nil isJoystick:false];
}

-(void)vcCamera {
    [self sendWithString:@"Commands.SetVirtualCockpitCameraCommand" params:nil isJoystick:false];
}

-(void)followCamera{
    [self sendWithString:@"Commands.SetFollowCameraCommand" params:nil isJoystick:false];
}

-(void)onboardCamera {
    [self sendWithString:@"Commands.SetOnboardCameraCommand" params:nil isJoystick:false];
}

-(void)towerCamera {
    [self sendWithString:@"Commands.SetTowerCameraCommand" params:nil isJoystick:false];
}

-(void)flybyCamera {
    [self sendWithString:@"Commands.SetFlybyCamera" params:nil isJoystick:false];
}

-(void)zoomOut {
    [self sendWithString:@"Commands.CameraZoomOut" params:nil isJoystick:false];
}

-(void)zoomIn {
    [self sendWithString:@"Commands.CameraZoomIn" params:nil isJoystick:false];
}

/*
    Airplane State
    ========================
*/

-(void)flapsDown {
     [self sendWithString:@"Commands.FlapsDown" params:nil isJoystick:false];
}

-(void)flapsUp {
    [self sendWithString:@"Commands.FlapsUp" params:nil isJoystick:false];
}

-(void)landingGear {
    [self sendWithString:@"Commands.LandingGear" params:nil isJoystick:false];
}

-(void)spoilers {
    [self sendWithString:@"Commands.Spoilers" params:nil isJoystick:false];
}

-(void)reverseThrust {
    [self sendWithString:@"Commands.ReverseThrust" params:nil isJoystick:false];
}

-(void)parkingBrakes {
    [self sendWithString:@"Commands.ParkingBrakes" params:nil isJoystick:false];
}

-(void)pushback {
    [self sendWithString:@"Commands.Pushback" params:nil isJoystick:false];
}


/*
     Autopilot
     ========================
*/

-(void)autopilot {
    [self sendWithString:@"Commands.Autopilot.Toggle" params:nil isJoystick:false];
}


/*
    General
    ========================
*/

-(void)hud {
    [self sendWithString:@"Commands.ToggleHUD" params:nil isJoystick:false];
}

-(void)togglePause {
    [self sendWithString:@"Commands.TogglePause" params:nil isJoystick:false];
}


/*
    Control Surfaces
    ========================
*/

-(void)trimUp {
    [self sendWithString:@"Commands.ElevatorTrimUp" params:nil isJoystick:false];
}

-(void)trimDown {
    [self sendWithString:@"Commands.ElevatorTrimDown" params:nil isJoystick:false];
}

-(void)rollLeft {
    [self sendWithString:@"Commands.RollLeft" params:nil isJoystick:false];
}

-(void)rollRight {
    [self sendWithString:@"Commands.RollRight" params:nil isJoystick:false];
}

-(void)pitchUp {
    [self sendWithString:@"Commands.PitchUp" params:nil isJoystick:false];
}

-(void)pitchDown {
    [self sendWithString:@"Commands.PitchDown" params:nil isJoystick:false];
}

/*
     Live
     ========================
*/

-(void)atcMenu {
    [self sendWithString:@"Commands.ShowATCWindowCommand" params:nil isJoystick:false];
}

-(void)atc1 {
    [self sendWithString:@"Commands.ATCEntry1" params:nil isJoystick:false];
}

-(void)atc2 {
    [self sendWithString:@"Commands.ATCEntry2" params:nil isJoystick:false];
}


-(void)atc3 {
    [self sendWithString:@"Commands.ATCEntry3" params:nil isJoystick:false];
}


-(void)atc4 {
    [self sendWithString:@"Commands.ATCEntry4" params:nil isJoystick:false];
}


-(void)atc5 {
    [self sendWithString:@"Commands.ATCEntry5" params:nil isJoystick:false];
}


-(void)atc6 {
    [self sendWithString:@"Commands.ATCEntry6" params:nil isJoystick:false];
}


-(void)atc7 {
    [self sendWithString:@"Commands.ATCEntry7" params:nil isJoystick:false];
}


-(void)atc8 {
    [self sendWithString:@"Commands.ATCEntry8" params:nil isJoystick:false];
}


-(void)atc9 {
    [self sendWithString:@"Commands.ATCEntry9" params:nil isJoystick:false];
}


-(void)atc10 {
    [self sendWithString:@"Commands.ATCEntry10" params:nil isJoystick:false];
}

/*
     Lighting
     ========================
 */

-(void)landing {
    [self sendWithString:@"Commands.LandingLights" params:nil isJoystick:false];
}

-(void)nav {
    [self sendWithString:@"Commands.NavLights" params:nil isJoystick:false];
}

-(void)strobe {
    [self sendWithString:@"Commands.StrobeLights" params:nil isJoystick:false];
}

-(void)beacon {
    [self sendWithString:@"Commands.BeaconLights" params:nil isJoystick:false];
}


@end
