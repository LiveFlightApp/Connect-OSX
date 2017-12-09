//
//  UDPReceiver.m
//  LiveFlight
//
//  Created by Cameron Carmichael Alonso on 08/10/15.
//  Copyright © 2015 Cameron Carmichael Alonso. All rights reserved.
//

#import "UDPReceiver.h"

@implementation UDPReceiver
@synthesize udpSocket = udpSocket_;
@synthesize connected;

-(id)copyWithZone:(NSZone*) zone {
    
    return self;
}

-(void)startUDPListener {


    if (udpSocket_ == nil) {
        
        [self setupSocket];
        
    }
    
    
}

- (void)setupSocket {
    
    int port = 15000; //IF broadcasts on 15000
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"manualIP"] == true) {
        
        // manual IP mode is enabled, ignore UDP search
        
        InfiniteFlightAPIConnector *apiConnector = [[InfiniteFlightAPIConnector alloc] init];
        [apiConnector connectToInfiniteFlightWithIP:[[NSUserDefaults standardUserDefaults] valueForKey:@"manualIPValue"]];
        
        
    } else {
    
        NSLog(@"Starting UDP listener on port %d", port);
        
        udpSocket_ = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        // disable IPV6
        [udpSocket_ setIPv4Enabled:true];
        [udpSocket_ setIPv6Enabled:false];
        
        NSError *error = nil;
        
        if (![udpSocket_ bindToPort:port error:&error])
        {
            NSLog(@"Error binding: %@", error);
            return;
        }
        if (![udpSocket_ beginReceiving:&error])
        {
            NSLog(@"Error starting server: %@", error);
            return;
        }
        
        NSError *receivingError;
        [udpSocket_ beginReceiving:&receivingError];
            
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    //received packet on port 15000

    NSString *packet = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (packet) {
        
        NSLog(@"Received packet: %@", packet);
        
        //read json
        NSError *error = nil;
        id object = [NSJSONSerialization
                     JSONObjectWithData:data
                     options:0
                     error:&error];
        
        if(!error) {
            
            if([object isKindOfClass:[NSDictionary class]])
            {
                NSDictionary *results = object;
                
                if (connected != true) {
                    
                    NSLog(@"Can connect to one of these: %@", [results valueForKey:@"Addresses"]);
                   
                    NSArray *possibleAddresses = [results mutableArrayValueForKey:@"Addresses"];
                    NSString *ipToConnectTo;
                    
                    // Prioritise IPv4 if possible
                    // Regex thanks to https://www.mkyong.com/regular-expressions/how-to-validate-ip-address-with-regular-expression/
                    NSString *regex = [NSString stringWithFormat:@"^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\.([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\.([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\.([01]?\\d\\d?|2[0-4]\\d|25[0-5])$"];
                    NSPredicate *filter = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
                    NSArray *matches = [possibleAddresses filteredArrayUsingPredicate:filter];
                    
                    NSLog(@"IPv4 priority chooses one of these: %@", matches);
                    
                    if (matches.count) {
                        ipToConnectTo = [matches firstObject];
                    } else {
                        if (possibleAddresses.count) {
                            ipToConnectTo = [possibleAddresses firstObject];
                        } else {
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"tcpError" object:nil];
                        }
                    }
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        [self connectIF:ipToConnectTo];
                    });
                    
                    connected = true;
                    
                    [udpSocket_ close];
                    udpSocket_.delegate = nil;
                    
                }

            }
            
        }
        
    } else {
        NSString *host = nil;
        uint16_t port = 0;
        [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
        
        NSLog(@"Unknown message on port %d", port);
    }
}

-(void)connectIF:(NSString *)string {
    
    InfiniteFlightAPIConnector *apiConnector = [[InfiniteFlightAPIConnector alloc] init];
    [apiConnector connectToInfiniteFlightWithIP:string];
    
    
}

@end

