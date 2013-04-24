//
//  RBCountDownClock.m
//  CountDown
//
//  Created by Rachel Brindle on 3/21/13.
//  Copyright (c) 2013 Rachel Brindle. All rights reserved.
//

#import "RBCountDownClock.h"
#import "RBPreferences.h"

#define M_TAU (2*M_PI)

@implementation RBCountDownClock

-(id)initWithFrame:(NSRect)frameRect statusItem:(BOOL)isStatusBar
{
    if ((self = [super initWithFrame:frameRect]) != nil) {
        [self commonInit:isStatusBar];
    }
    return self;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit:NO];
    }
    
    return self;
}

-(void)commonInit:(bool)statusItem
{
    isStatusItem = statusItem;
    if (isStatusItem) {
        //[self setL]
        statusFrame = _frame;
    }
    isMenuVisible = NO;
    NSRect frame = _frame;
    time = 0;
    al = 10;
    t = [NSTimer scheduledTimerWithTimeInterval:1.0/30.0 target:self selector:@selector(runTimeStuff) userInfo:nil repeats:YES];
    
    //[self addSubview:seconds];
    
    double x = frame.origin.x + (frame.size.width / 2.0);
    double y = frame.origin.y + (frame.size.height / 2.0);
    double a = frame.size.width / 2.0;
    if (frame.size.height < frame.size.width)
        a = frame.size.height / 2.0;
    
    arms = [[RBClockArms alloc] initWithFrame:NSMakeRect(x-a, y-a, a*2, 2*2)];
    arms.statusItem = isStatusItem;
    
    al = a;
    
    [self addSubview:arms];
}

-(void)updateTime:(NSTimeInterval)newTime
{
    time = newTime;
}

-(void)runTimeStuff
{
    time -= 1.0/30.0;
    if (time < 0)
        time = 0;
    [arms updateTime:time];
    [arms display];
}

-(void)mouseDown:(NSEvent *)theEvent
{
    if (isStatusItem) {
        [[self menu] setDelegate:self];
        [_statusItem popUpStatusItemMenu:[self menu]];
    }
    [self setNeedsDisplay:YES];
}

-(void)menuWillOpen:(NSMenu *)menu
{
    isMenuVisible = YES;
    [self setNeedsDisplay:YES];
}

-(void)menuDidClose:(NSMenu *)menu
{
    isMenuVisible = NO;
    [menu setDelegate:nil];
    [self setNeedsDisplay:YES];
}

-(NSColor *)titleForegroundColor {
    if (isMenuVisible)
        return [NSColor whiteColor];
    else
        return [NSColor blackColor];
}

- (void)drawRect:(NSRect)dirtyRect
{
    if (isStatusItem) {
        [_statusItem drawStatusBarBackgroundInRect:[self bounds] withHighlight:isMenuVisible];
    }
    ///*
    NSRect frameRect = dirtyRect;
    double x = frameRect.origin.x + (frameRect.size.width / 2.0);
    double y = frameRect.origin.y + (frameRect.size.height / 2.0);
    double a = frameRect.size.width / 2.0;
    if (frameRect.size.height < frameRect.size.width)
        a = frameRect.size.height / 2.0;
    NSRect r = NSMakeRect(x-a, y-a, a*2, a*2);
    if (isStatusItem) {
        y = 11;
        a = 8;
        r = NSMakeRect(x-a, y-a, a*2, a*2);
    }
    
    [arms setFrame:r];
    al = a;
    
    NSBezierPath *circle = [NSBezierPath bezierPathWithOvalInRect:r];
    [[self titleForegroundColor] set];
    if (!_statusItem) {
        [[NSColor whiteColor] setFill];
        double jl = al * 0.9;
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
      //*/
}

/*
-(void)setFrame:(NSRect)frameRect
{
    double x = frameRect.origin.x + (frameRect.size.width / 2.0);
    double y = frameRect.origin.y + (frameRect.size.height / 2.0);
    double a = frameRect.size.width / 2.0;
    if (frameRect.size.height < frameRect.size.width)
        a = frameRect.size.height / 2.0;
    NSRect r = NSMakeRect(x-a, y-a, a*2, a*2);
    
    [cv setFrame:r];
    [arms setFrame:NSMakeRect(0, 0, a*2, a*2)];
    [cv setNeedsDisplay:YES];
    al = a;
    //_frame = frameRect;
    [super setFrame:frameRect];
}
//*/

@end
