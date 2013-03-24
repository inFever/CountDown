//
//  RBCountDownClock.m
//  CountDown
//
//  Created by Rachel Brindle on 3/21/13.
//  Copyright (c) 2013 Rachel Brindle. All rights reserved.
//

#import "RBCountDownClock.h"

#define M_TAU (2*M_PI)

@implementation RBCountDownClock

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        time = 0;
        al = 10;
        t = [NSTimer scheduledTimerWithTimeInterval:1.0/30.0 target:self selector:@selector(runTimeStuff) userInfo:nil repeats:YES];
        cv = [[RBClockView alloc] initWithFrame:frame];
        [self addSubview:cv];
    }
    
    return self;
}

-(void)updateTime:(NSTimeInterval)newTime
{
    time = newTime;
}

-(void)runTimeStuff
{
    time -= 1.0/30.0;
    [self display];
    //[self setNeedsDisplay:YES];
}

-(double)convertHourToRadian:(double)hour
{
    // each hour = 1/12 tau
    hour *= -1;
    return ((hour/12.0) * M_TAU) + (M_TAU / 4.0);
}

-(double)convertMinuteToRadian:(double)minute
{
    return [self convertHourToRadian:minute/5.0];
}

-(double)poorMansMod:(double)n modulus:(double)mod
{
    while (n > mod)
        n -= mod;
    return n;
}

bool rectsAreSame(NSRect a, NSRect b)
{
    return a.origin.x == b.origin.x &&
           a.origin.y == b.origin.y &&
           a.size.width == b.size.width &&
           a.size.height == b.size.height;
}

- (void)drawRect:(NSRect)dirtyRect
{
    double x = dirtyRect.origin.x + (dirtyRect.size.width / 2.0);
    double y = dirtyRect.origin.y + (dirtyRect.size.height / 2.0);
    double a = dirtyRect.size.width / 2.0;
    if (dirtyRect.size.height < dirtyRect.size.width)
        a = dirtyRect.size.height / 2.0;
    if (a != al || x != cv.frame.origin.x || y != cv.frame.origin.y) {
        [cv setFrame:NSMakeRect(x-a, y-a, a*2, a*2)];
        [cv setNeedsDisplay:YES];
        al = a;
    }
    NSPoint center = NSMakePoint(x, y);
    NSPoint weekPoint, dayPoint, hourPoint, minutePoint, secondPoint;
    double s, m, h, d, w;
    s = time;
    d = s / (60*60*24);
    m = s / 60;
    h = [self poorMansMod:(m / 60) modulus:24];
    m = [self poorMansMod:m modulus:60];
    s = [self poorMansMod:s modulus:60];
    w = d / 7;
    d = [self poorMansMod:d modulus:7];
    
    double wRad = [self convertHourToRadian:w];
    double dRad = [self convertHourToRadian:d];
    double hRad = [self convertHourToRadian:h];
    double mRad = [self convertMinuteToRadian:m];
    double sRad = [self convertMinuteToRadian:s];
    weekPoint   = NSMakePoint(x + al*cos(wRad), y + al*sin(wRad));
    dayPoint    = NSMakePoint(x + al*cos(dRad), y + al*sin(dRad));
    hourPoint   = NSMakePoint(x + al*cos(hRad), y + al*sin(hRad));
    minutePoint = NSMakePoint(x + al*cos(mRad), y + al*sin(mRad));
    secondPoint = NSMakePoint(x + al*cos(sRad), y + al*sin(sRad));
    
    NSBezierPath *lines;
    
    lines = [NSBezierPath bezierPath];
    [lines moveToPoint:center];
    [lines lineToPoint:weekPoint];
    [[NSColor blueColor] set];
    [lines stroke];
    
    lines = [NSBezierPath bezierPath];
    [lines moveToPoint:center];
    [lines lineToPoint:dayPoint];
    [[NSColor colorWithSRGBRed:0 green:0.5 blue:1.0 alpha:1.0] set];
    [lines stroke];
    
    lines = [NSBezierPath bezierPath];
    [lines moveToPoint:center];
    [lines lineToPoint:hourPoint];
    [[NSColor greenColor] set];
    [lines stroke];
    
    lines = [NSBezierPath bezierPath];
    [lines moveToPoint:center];
    [lines lineToPoint:minutePoint];
    [[NSColor orangeColor] set];
    [lines stroke];
    
    lines = [NSBezierPath bezierPath];
    [lines moveToPoint:center];
    [lines lineToPoint:secondPoint];
    [[NSColor redColor] set];
    [lines stroke];
}

@end
