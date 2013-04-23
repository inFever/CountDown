//
//  RBCountDownClock.h
//  CountDown
//
//  Created by Rachel Brindle on 3/21/13.
//  Copyright (c) 2013 Rachel Brindle. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "RBClockView.h"

#import "RBLine.h"

@interface RBCountDownClock : NSView <NSMenuDelegate>
{
    NSTimeInterval time;
    double al;
    NSTimer *t;
    RBClockView *cv;
    
    bool isStatusItem;
    bool isMenuVisible;
    
    void (^onClick)(void);
    
    RBLine *weeks, *days, *hours, *minutes, *seconds;
}

@property (nonatomic, weak) NSStatusItem *statusItem;

-(id)initWithFrame:(NSRect)frameRect statusItem:(BOOL)isStatusBar;
-(void)setOnClick:(void (^)(void))action;
-(void)updateTime:(NSTimeInterval)newTime;

@end
