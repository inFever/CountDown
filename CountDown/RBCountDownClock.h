//
//  RBCountDownClock.h
//  CountDown
//
//  Created by Rachel Brindle on 3/21/13.
//  Copyright (c) 2013 Rachel Brindle. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "RBClockView.h"

@interface RBCountDownClock : NSView
{
    NSTimeInterval time;
    double al;
    NSTimer *t;
    RBClockView *cv;
}

-(void)updateTime:(NSTimeInterval)newTime;

@end
