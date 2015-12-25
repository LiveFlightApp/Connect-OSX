//
//  InfiniteFlightAPIConnector.h
//  LiveFlight
//
//  Created by Cameron Carmichael Alonso on 03/09/15.
//  Copyright (c) 2015 Cameron Carmichael Alonso. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InfiniteFlightAPIConnector:NSObject <NSStreamDelegate> {
@public
    NSString *host;
    int port;
    NSDate *lastSend;
}

- (void)open;
- (void)close;
- (void)readIn:(NSString *)s;

-(void)connectToInfiniteFlightWithIP:(NSString *)ip;

//joystick
-(void)didMoveAxis:(int)axis value:(int)value;
-(void)didPressButton:(int)button state:(int)state;

//commands
-(void)previousCamera;
-(void)nextCamera;
-(void)cockpitCamera;
-(void)vcCamera;
-(void)followCamera;
-(void)onboardCamera;
-(void)towerCamera;
-(void)flybyCamera;
-(void)flapsDown;
-(void)flapsUp;
-(void)landingGear;
-(void)spoilers;
-(void)reverseThrust;
-(void)autopilot;
-(void)hud;
-(void)parkingBrakes;
-(void)togglePause;
-(void)pushback;
-(void)trimUp;
-(void)trimDown;
-(void)atcMenu;
-(void)landing;
-(void)nav;
-(void)strobe;
-(void)beacon;
-(void)atc1;
-(void)atc2;
-(void)atc3;
-(void)atc4;
-(void)atc5;
-(void)atc6;
-(void)atc7;
-(void)atc8;
-(void)atc9;
-(void)atc10;
-(void)zoomOut;
-(void)zoomIn;

@end
