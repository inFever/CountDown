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

-(void)setOnClick:(void (^)(void))action
{
    onClick = action;
}

-(void)commonInit:(bool)statusItem
{
    isStatusItem = statusItem;
    isMenuVisible = NO;
    NSRect frame = _frame;
    time = 0;
    al = 10;
    t = [NSTimer scheduledTimerWithTimeInterval:1.0/30.0 target:self selector:@selector(runTimeStuff) userInfo:nil repeats:YES];
    cv = [[RBClockView alloc] initWithFrame:frame];
    
    //[self addSubview:seconds];
    
    double x = frame.origin.x + (frame.size.width / 2.0);
    double y = frame.origin.y + (frame.size.height / 2.0);
    double a = frame.size.width / 2.0;
    if (frame.size.height < frame.size.width)
        a = frame.size.height / 2.0;
    [cv setFrame:NSMakeRect(x-a, y-a, a*2, a*2)];
    [cv setStatusItem:statusItem];
    [cv setNeedsDisplay:YES];
    
    al = a;
    
    [self addSubview:cv];
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
    
    [self display];
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

-(void)mouseDown:(NSEvent *)theEvent
{
    if (onClick)
        onClick();
    if (isStatusItem) {
        [[self menu] setDelegate:self];
        [_statusItem popUpStatusItemMenu:[self menu]];
    }
    [cv setDrawColor:[self titleForegroundColor]];
    [cv setNeedsDisplay:YES];
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
    double x = dirtyRect.origin.x + (dirtyRect.size.width / 2.0);
    double y = dirtyRect.origin.y + (dirtyRect.size.height / 2.0);
    double a = dirtyRect.size.width / 2.0;
    if (dirtyRect.size.height < dirtyRect.size.width)
        a = dirtyRect.size.height / 2.0;
    if (isStatusItem) {
        y = 11;
        a = 8;
    }
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
    
    NSColor *week, *day, *hour, *minute, *second;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSData *data;
    data = [ud objectForKey:WEEK_KEY];
    if (data)
        week = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if (!week) {
        week = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        week = [NSColor magentaColor];
        data = [NSKeyedArchiver archivedDataWithRootObject:week];
        [ud setObject:data forKey:WEEK_KEY];
    }
    data = [ud objectForKey:DAY_KEY];
    if (data)
        day = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if (!day) {
        day = [NSColor blueColor];
        data = [NSKeyedArchiver archivedDataWithRootObject:day];
        [ud setObject:data forKey:DAY_KEY];
    }
    data = [ud objectForKey:HOUR_KEY];
    if (data)
        hour = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if (!hour) {
        hour = [NSColor greenColor];
        data = [NSKeyedArchiver archivedDataWithRootObject:hour];
        [ud setObject:data forKey:HOUR_KEY];
    }
    data = [ud objectForKey:MINUTE_KEY];
    if (data)
        minute = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if (!minute) {
        minute = [NSColor orangeColor];
        data = [NSKeyedArchiver archivedDataWithRootObject:minute];
        [ud setObject:data forKey:MINUTE_KEY];
    }
    data = [ud objectForKey:SECOND_KEY];
    if (data)
        second = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if (!second) {
        second = [NSColor redColor];
        data = [NSKeyedArchiver archivedDataWithRootObject:second];
        [ud setObject:data forKey:SECOND_KEY];
    }
    
    lines = [NSBezierPath bezierPath];
    [lines moveToPoint:center];
    [lines lineToPoint:weekPoint];
    [week set];
    [lines stroke];
    
    lines = [NSBezierPath bezierPath];
    [lines moveToPoint:center];
    [lines lineToPoint:dayPoint];
    [day set];
    [lines stroke];
    
    lines = [NSBezierPath bezierPath];
    [lines moveToPoint:center];
    [lines lineToPoint:hourPoint];
    [hour set];
    [lines stroke];
    
    lines = [NSBezierPath bezierPath];
    [lines moveToPoint:center];
    [lines lineToPoint:minutePoint];
    [minute set];
    [lines stroke];
    
    lines = [NSBezierPath bezierPath];
    [lines moveToPoint:center];
    [lines lineToPoint:secondPoint];
    [second set];
    [lines stroke];
}

@end
