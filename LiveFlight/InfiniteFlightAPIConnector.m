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
    
    //setup status fetcher
    while (true)
    {
        
        [self sendWithString:@"Airplane.GetState" params:[NSArray array]];
        sleep(2000);
        
    }
    
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
    }
}


- (void)readIn:(NSString *)s {
    NSLog(@"Reading: %@", s);
}

-(void)sendWithString:(NSString *)string params:(NSArray *)params {
    
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
        
        if (timePassed > 20) {
            
            //been longer than 20ms, send with less risk of overloading server
            
            NSInteger sent = [outputStream write:result.bytes maxLength:result.length];
            NSLog(@"Write result: %ld", (long)sent);
            if (sent == -1) {
                //error. probably disconnected
                [[NSNotificationCenter defaultCenter] postNotificationName:@"tcpError" object:nil];
            }
            
        } else {
            //NSLog(@"Ignoring packet, too soon since previous...");
        }
        
        lastSend = [NSDate date];
        
    });

}


#pragma mark joystick actions
-(void)didMoveAxis:(int)axis value:(int)value {
    
    NSString *param = [NSString stringWithFormat:@"{\"Name\":\"%d\",\"Value\":\"%d\"}", axis, value];
    
    NSData *data = [param dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    NSArray *params = [NSArray arrayWithObjects:json, nil];
    
    [self sendWithString:@"NetworkJoystick.SetAxisValue" params:params];
    
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
    
    [self sendWithString:@"NetworkJoystick.SetButtonState" params:params];
    
    
}

#pragma mark commands

-(void)previousCamera {
    [self sendWithString:@"Commands.PrevCamera" params:nil];
}

-(void)nextCamera {
    [self sendWithString:@"Commands.NextCamera" params:nil];
}

-(void)cockpitCamera {
    [self sendWithString:@"Commands.SetCockpitCamera" params:nil];
}

-(void)vcCamera {
    [self sendWithString:@"Commands.SetVirtualCockpitCameraCommand" params:nil];
}

-(void)followCamera{
    [self sendWithString:@"Commands.SetFollowCameraCommand" params:nil];
}

-(void)onboardCamera {
    [self sendWithString:@"Commands.SetOnboardCameraCommand" params:nil];
}

-(void)towerCamera {
    [self sendWithString:@"Commands.SetTowerCameraCommand" params:nil];
}

-(void)flybyCamera {
    [self sendWithString:@"Commands.SetFlybyCamera" params:nil];
}

-(void)flapsDown {
     [self sendWithString:@"Commands.FlapsDown" params:nil];
}

-(void)flapsUp {
    [self sendWithString:@"Commands.FlapsUp" params:nil];
}

-(void)landingGear {
    [self sendWithString:@"Commands.LandingGear" params:nil];
}

-(void)spoilers {
    [self sendWithString:@"Commands.Spoilers" params:nil];
}

/*
-(void)movePOV(int value)
{
    //POV axis
    var xValue = 0;
    var yValue = 0;
    
    Console.WriteLine(value);
    
    if (value == viewUpId)
    {
        xValue = 0;
        yValue = -1;
    }
    else if (value == viewDownId)
    {
        xValue = 0;
        yValue = 1;
    }
    else if (value == viewLeftId)
    {
        xValue = -1;
        yValue = 0;
    }
    else if (value == viewRightId)
    {
        xValue = 1;
        yValue = 0;
    }
    
    Console.WriteLine(xValue + "  " + yValue);
    
    client.ExecuteCommand("NetworkJoystick.SetPOVState", new CallParameter[]
                          {
                              new CallParameter
                              {
                                  Name = "X",
                                  Value = xValue.ToString()
                              },
                              new CallParameter
                              {
                                  Name = "Y",
                                  Value = yValue.ToString()
                              }
                          });
    
}
*/

-(void)reverseThrust {
    [self sendWithString:@"Commands.ReverseThrust" params:nil];
}

-(void)autopilot {
    [self sendWithString:@"Commands.Autopilot.Toggle" params:nil];
}

-(void)hud {
    [self sendWithString:@"Commands.ToggleHUD" params:nil];
}

-(void)parkingBrakes {
    [self sendWithString:@"Commands.ParkingBrakes" params:nil];
}

-(void)togglePause {
    [self sendWithString:@"Commands.TogglePause" params:nil];
}

-(void)pushback {
    [self sendWithString:@"Commands.Pushback" params:nil];
}

-(void)trimUp {
    [self sendWithString:@"Commands.ElevatorTrimUp" params:nil];
}

-(void)trimDown {
    [self sendWithString:@"Commands.ElevatorTrimDown" params:nil];
}

-(void)atcMenu {
    [self sendWithString:@"Commands.ShowATCWindowCommand" params:nil];
}

-(void)landing {
    [self sendWithString:@"Commands.LandingLights" params:nil];
}

-(void)nav {
    [self sendWithString:@"Commands.NavLights" params:nil];
}

-(void)strobe {
    [self sendWithString:@"Commands.StrobeLights" params:nil];
}

-(void)beacon {
    [self sendWithString:@"Commands.BeaconLights" params:nil];
}

-(void)atc1 {
    [self sendWithString:@"Commands.ATCEntry1" params:nil];
}

-(void)atc2 {
    [self sendWithString:@"Commands.ATCEntry2" params:nil];
}


-(void)atc3 {
    [self sendWithString:@"Commands.ATCEntry3" params:nil];
}


-(void)atc4 {
    [self sendWithString:@"Commands.ATCEntry4" params:nil];
}


-(void)atc5 {
    [self sendWithString:@"Commands.ATCEntry5" params:nil];
}


-(void)atc6 {
    [self sendWithString:@"Commands.ATCEntry6" params:nil];
}


-(void)atc7 {
    [self sendWithString:@"Commands.ATCEntry7" params:nil];
}


-(void)atc8 {
    [self sendWithString:@"Commands.ATCEntry8" params:nil];
}


-(void)atc9 {
    [self sendWithString:@"Commands.ATCEntry9" params:nil];
}


-(void)atc10 {
    [self sendWithString:@"Commands.ATCEntry10" params:nil];
}


-(void)zoomOut {
    [self sendWithString:@"Commands.CameraZoomOut" params:nil];
}

-(void)zoomIn {
    [self sendWithString:@"Commands.CameraZoomIn" params:nil];
}


@end
