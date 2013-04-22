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

@interface RBCountDownClock : NSView
{
    NSTimeInterval time;
    double al;
    NSTimer *t;
    RBClockView *cv;
    
    RBLine *weeks, *days, *hours, *minutes, *seconds;
}

-(void)updateTime:(NSTimeInterval)newTime;

@end
