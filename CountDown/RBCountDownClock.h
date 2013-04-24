//
//  RBCountDownClock.h
//  CountDown
//
//  Created by Rachel Brindle on 3/21/13.
//  Copyright (c) 2013 Rachel Brindle. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "RBClockArms.h"

@interface RBCountDownClock : NSView <NSMenuDelegate>
{
    NSTimeInterval time;
    double al;
    NSTimer *t;
    RBClockArms *arms;
    
    NSRect statusFrame;
    
    bool isStatusItem;
    bool isMenuVisible;
}

@property (nonatomic, weak) NSStatusItem *statusItem;

-(id)initWithFrame:(NSRect)frameRect statusItem:(BOOL)isStatusBar;
-(void)updateTime:(NSTimeInterval)newTime;

@end
