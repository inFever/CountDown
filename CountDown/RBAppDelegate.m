//
//  RBAppDelegate.m
//  CountDown
//
//  Created by Rachel Brindle on 3/21/13.
//  Copyright (c) 2013 Rachel Brindle. All rights reserved.
//

#import "RBAppDelegate.h"

@implementation RBAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [[self window] setLevel:NSFloatingWindowLevel];
    [[[self window] standardWindowButton:NSWindowCloseButton] setEnabled:NO];
    date = [NSDate dateWithString:@"2013-05-03 15:00:00 -0700"];
    dp.dateValue = date;
    dp.delegate = self;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(updateThread) object:nil];
    [thread start];
}

-(NSString *)number:(int)n catString:(NSString *)s
{
    NSString *ret = [NSString stringWithFormat:@" %d %@", n, s];
    if (n != 1)
        ret = [ret stringByAppendingString:@"s"];
    return ret;
}

-(void)datePickerCell:(NSDatePickerCell *)aDatePickerCell validateProposedDateValue:(NSDate *__autoreleasing *)proposedDateValue timeInterval:(NSTimeInterval *)proposedTimeInterval
{
    date = *proposedDateValue;
    [self internalUpdate];
}

-(void)internalUpdate
{
    NSTimeInterval i = [date timeIntervalSinceNow];
    int t = (int)i;
    int s, m, h, d, w;
    s = (int)ceil(t);
    d = s / (60*60*24);
    m = s / 60;
    h = (m / 60) % 24;
    h = h % 24;
    m = m % 60;
    s = s % 60;
    w = d / 7;
    d = d % 7;
        
    NSString *toDisplay = @"";
    if (w)
        toDisplay = [toDisplay stringByAppendingString:[self number:w catString:@"week"]];
    if (d)
        toDisplay = [toDisplay stringByAppendingString:[self number:d catString:@"day"]];
    if (h)
        toDisplay = [toDisplay stringByAppendingString:[self number:h catString:@"hour"]];
    if (m)
        toDisplay = [toDisplay stringByAppendingString:[self number:m catString:@"minute"]];
    if (s)
        toDisplay = [toDisplay stringByAppendingString:[self number:s catString:@"second"]];
    tf.stringValue = toDisplay;
    dispatch_async(dispatch_get_main_queue(), ^{[cdc updateTime:i];});
}


-(void)updateThread
{
    while (1) {
        [self internalUpdate];
        [NSThread sleepForTimeInterval:1.0/30.0];
    }
}

-(void)windowDidBecomeMain:(NSNotification *)notification
{
    [[self window] setLevel:NSNormalWindowLevel];
}

-(void)windowDidResignMain:(NSNotification *)notification
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DefaultAlwaysOnTop"]) {
        [[self window] setLevel:NSFloatingWindowLevel];
    } else {
        [[self window] setLevel:NSNormalWindowLevel];
    }
}

@end
