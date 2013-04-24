//
//  RBClockView.m
//  CountDown
//
//  Created by Rachel Brindle on 3/22/13.
//  Copyright (c) 2013 Rachel Brindle. All rights reserved.
//

#import "RBClockView.h"

#define M_TAU (2*M_PI)

@implementation RBClockView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        _drawColor = [NSColor blackColor];
        
        //arms = [[RBClockArms alloc] initWithFrame:frame];
        //[self addSubview:arms];
    }
    
    return self;
}

-(void)update:(NSTimeInterval)time
{
    [arms updateTime:time];
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSBezierPath *circle = [NSBezierPath bezierPathWithOvalInRect:dirtyRect];
    [_drawColor set];
    if (!_statusItem) {
        [[NSColor whiteColor] setFill];
        double x, y;
        double al = dirtyRect.size.width/2.0;
        double jl = al * 0.9;
        x = dirtyRect.origin.x + al;
        y = dirtyRect.origin.y + al;
        for (int i = 0; i < 12; i++) {
            double j = i/12.0;
            double rad = j*M_TAU;
            NSPoint p,q;
            p = NSMakePoint(x+(jl*cos(rad)), y+(jl*sin(rad)));
            q = NSMakePoint(x+(al*cos(rad)), y+(al*sin(rad)));
            [circle moveToPoint:p];
            [circle lineToPoint:q];
        }
        jl = al * 0.975;
        for (int i = 0; i < 60; i++) {
            if (i % 5 == 0)
                continue;
            double j = i/60.0;
            double rad = j*M_TAU;
            NSPoint p,q;
            p = NSMakePoint(x+(jl*cos(rad)), y+(jl*sin(rad)));
            q = NSMakePoint(x+(al*cos(rad)), y+(al*sin(rad)));
            [circle moveToPoint:p];
            [circle lineToPoint:q];
        }
        [circle fill];
    }
    [circle stroke];
}

@end
