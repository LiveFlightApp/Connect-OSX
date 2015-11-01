//
//  ControlPad.m
//  LiveFlight
//
//  Created by Cameron Carmichael Alonso on 17/10/15.
//  Copyright © 2015 Cameron Carmichael Alonso. All rights reserved.
//

#import "ControlPad.h"


@implementation ControlPad


-(void)updateTrackingAreas
{
    if(trackingArea != nil) {
        [self removeTrackingArea:trackingArea];
    }
    
    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
    trackingArea = [ [NSTrackingArea alloc] initWithRect:[self bounds]
                                            options:opts
                                            owner:self
                                            userInfo:nil];
    [self addTrackingArea:trackingArea];
}

-(void)mouseEntered:(NSEvent *)theEvent {
    
    NSLog(@"Mouse entered area");
    inArea = true;
    
}

-(void)mouseExited:(NSEvent *)theEvent {
    
    NSLog(@"Mouse exited area");
    inArea = false;
    
}

- (void)mouseMoved:(NSEvent *)event {
    
    if (inArea == true) {
        
        if (selected == true) {
        
            NSPoint location = [self convertPoint:[event locationInWindow] fromView:nil];
           
            int locX = ((location.x * 2) - 256) * 4; //bring up to be a total of 1024
            int locY = ((location.y * 2) - 256) * 4;
            
            NSLog(@"Location: %d, %d", locX, locY);
            
            AppDelegate *delegate =  [[NSApplication sharedApplication] delegate];
            InfiniteFlightAPIConnector *connector = delegate.connector;
            [connector didMoveAxis:0 value:locY];
            [connector didMoveAxis:1 value:locX];
            
        }
        
    }
}

-(void)mouseDown:(NSEvent *)theEvent {
   
    if (selected == true) {
        selected = false;
    } else if (selected == false) {
        selected = true;
    }
    
}


-(void)resizeFrameBy:(int)value {
    
    NSRect frame = [self frame];
    [self setFrame:CGRectMake(frame.origin.x, 
                              frame.origin.x,
                              frame.size.width + value, 
                              frame.size.height + value
                            )];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor whiteColor] set];
    NSRectFill([self bounds]);
    [[self window] makeFirstResponder:self];
    [[self window] setAcceptsMouseMovedEvents:YES];
    

    NSRect thisViewSize = [self bounds];
    
    // Set the line color
    
    [[NSColor colorWithDeviceRed:0
                           green:(255/255.0)
                            blue:(255/255.0)
                           alpha:1] set];
    
    // Draw the vertical lines first
    
    NSBezierPath * verticalLinePath = [NSBezierPath bezierPath];
    
    int gridWidth = thisViewSize.size.width;
    int gridHeight = thisViewSize.size.height;
    
    int i;
    int currentSpacing = 10;
    
    while (i < gridWidth)
    {
        i = i + currentSpacing;
        
        NSPoint startPoint = {i,0};
        NSPoint endPoint = {i, gridHeight};
        
        [verticalLinePath setLineWidth:0.1];
        [verticalLinePath moveToPoint:startPoint];
        [verticalLinePath lineToPoint:endPoint];
        
    }
    
    // Draw the horizontal lines
    
    NSBezierPath * horizontalLinePath = [NSBezierPath bezierPath];
    
    i = 0;
    while (i < gridHeight)
    {
        i = i + currentSpacing;
        
        NSPoint startPoint = {0,i};
        NSPoint endPoint = {gridWidth, i};
        
        [horizontalLinePath setLineWidth:0.5];
        [horizontalLinePath moveToPoint:startPoint];
        [horizontalLinePath lineToPoint:endPoint];
        
    }
    
    [verticalLinePath stroke];
    [horizontalLinePath stroke];
    
}

@end
