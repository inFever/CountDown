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
    date = [NSDate dateWithString:@"2013-05-14 08:45:00 -0700"];
    dp.dateValue = date;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(updateThread) object:nil];
    [thread start];
}

-(NSString *)number:(int)n catString:(NSString *)s
{
    NSString *ret = [NSString stringWithFormat:@"%d %@", n, s];
    if (n != 1)
        ret = [ret stringByAppendingString:@"s "];
    return ret;
}

-(void)datePickerCell:(NSDatePickerCell *)aDatePickerCell validateProposedDateValue:(NSDate *__autoreleasing *)proposedDateValue timeInterval:(NSTimeInterval *)proposedTimeInterval
{
    date = *proposedDateValue;
}


-(void)updateThread
{
    NSTimeInterval i;
    while (1) {
        i = [date timeIntervalSinceNow];
        int t = (int)i;
        int s, m, h, d, w;
        s = t;
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
        [NSThread sleepForTimeInterval:1];
    }
}

@end