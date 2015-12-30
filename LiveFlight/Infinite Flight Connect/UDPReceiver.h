//
//  UDPReceiver.h
//  LiveFlight
//
//  Created by Cameron Carmichael Alonso on 08/10/15.
//  Copyright © 2015 Cameron Carmichael Alonso. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncUdpSocket.h"
#import "InfiniteFlightAPIConnector.h"

@interface UDPReceiver : NSObject <GCDAsyncUdpSocketDelegate>


@property (nonatomic, retain) GCDAsyncUdpSocket *udpSocket;
@property bool connected;

-(void)startUDPListener;
-(void)didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext;

@end
