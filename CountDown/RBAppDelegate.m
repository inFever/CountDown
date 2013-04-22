//
//  RBAppDelegate.m
//  CountDown
//
//  Created by Rachel Brindle on 3/21/13.
//  Copyright (c) 2013 Rachel Brindle. All rights reserved.
//

#import "RBAppDelegate.h"
#import <EventKit/EventKit.h>

@implementation RBAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    //[[self window] setLevel:NSFloatingWindowLevel];
    queue = dispatch_queue_create("queue", 0);
    [self retrieveEvents];
    
    title = @"Unknown";
    date = [NSDate dateWithString:@"2013-05-14 08:45:00 -0700"];
    dp.dateValue = date;
    dp.delegate = self;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(updateThread) object:nil];
    [thread start];
        
#ifdef TARGET_OS_MAC
    [_window setReleasedWhenClosed:NO];
    
    NSStatusBar *bar = [NSStatusBar systemStatusBar];
    barItem = [bar statusItemWithLength:NSVariableStatusItemLength];
    [barItem setTitle:@"CountDown"];
    [barItem setAction:@selector(showWindow)];
    [barItem setTarget:self];
    [barItem sendActionOn:NSLeftMouseUpMask];
#endif
}

-(void)retrieveEvents
{
    pubMenu = [[NSMenu alloc] initWithTitle:@"Events"];
    [pub setMenu:pubMenu];
    eventItems = [[NSMutableDictionary alloc] init];
    
    EKEventStore *rStore = [[EKEventStore alloc] initWithAccessToEntityTypes:EKEntityMaskReminder];
    EKEventStore *eStore = [[EKEventStore alloc] initWithAccessToEntityTypes:EKEntityMaskEvent];
#ifdef TARGET_OS_MAC
    [self updateRemindersFromStore:rStore];
    [self updateEventsFromStore:eStore];
#else // iOS
    [rStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
        if (granted)
            [self updateRemindersFromStore:rStore];
    }];
    [eStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (granted)
            [self updateEventsFromStore:eStore];
    }];
#endif
}

-(void)showWindow
{
    [_window makeKeyAndOrderFront:nil];
}

-(void)setEvent:(id)sender
{
    NSMenuItem *i = (NSMenuItem *)sender;
    NSString *key = [i title];
    date = (NSDate *)[eventItems objectForKey:key];
    title = key;
    dp.dateValue = date;
}

-(void)updateEventsFromStore:(EKEventStore *)store
{
    NSPredicate *predicate = [store predicateForEventsWithStartDate:[NSDate date] endDate:[NSDate distantFuture] calendars:nil];
    dispatch_async(queue, ^{
        NSArray *events = [store eventsMatchingPredicate:predicate];
        
        events = [events sortedArrayUsingComparator:^(id obj1, id obj2) {
            EKEvent *o1 = (EKEvent *)obj1;
            EKEvent *o2 = (EKEvent *)obj2;
            BOOL e1 = [o1 hasAlarms];
            BOOL e2 = [o2 hasAlarms];
            NSDate *d1, *d2;
            // Ascending: 1,2
            // Descending: 2,1
            // Sorted ret: 1,2
            if (e1 && !e2)
                return (NSComparisonResult)NSOrderedAscending;
            else if (!e1 && e2)
                return (NSComparisonResult)NSOrderedDescending;
            else if (!e1 && !e2)
                return (NSComparisonResult)NSOrderedSame;
            
            d1 = [[[o1 alarms] objectAtIndex:0] absoluteDate];
            d2 = [[[o2 alarms] objectAtIndex:0] absoluteDate];
            
            if ([d1 isEqualToDate:d2])
                return (NSComparisonResult)NSOrderedSame;
            else if (([d1 earlierDate:d2] == d1)) {
                if ([d1 timeIntervalSinceNow] > 0)
                    return (NSComparisonResult)NSOrderedDescending;
                else if ([d2 timeIntervalSinceNow] > 0)
                    return (NSComparisonResult)NSOrderedAscending;
                else
                    return (NSComparisonResult)NSOrderedSame;
            } else {
                if ([d2 timeIntervalSinceNow] > 0)
                    return (NSComparisonResult)NSOrderedAscending;
                else if ([d1 timeIntervalSinceNow] > 0)
                    return (NSComparisonResult)NSOrderedDescending;
                else
                    return (NSComparisonResult)NSOrderedSame;
            }
        }];
        _events = events;
        for (EKEvent *e in events) {
            NSDate *d = [[[e alarms] objectAtIndex:0] absoluteDate];
            NSString *t = [e title];
            NSMenuItem *i = [[NSMenuItem alloc] initWithTitle:t action:@selector(setEvent:) keyEquivalent:@""];
            [i setTarget:self];
            if (d != nil) {
                [pubMenu addItem:i];
                [eventItems setValue:d forKey:t];
            }
        }
    });
}

-(void)updateRemindersFromStore:(EKEventStore *)store
{
    NSPredicate *predicate = [store predicateForRemindersInCalendars:nil];
    
    [store fetchRemindersMatchingPredicate:predicate completion:^(NSArray *reminders) {
        reminders = [reminders sortedArrayUsingComparator:^(id obj1, id obj2) {
            EKReminder *o1 = (EKReminder *)obj1;
            EKReminder *o2 = (EKReminder *)obj2;
            BOOL e1 = [o1 hasAlarms];
            BOOL e2 = [o2 hasAlarms];
            NSDate *d1, *d2;
            // Ascending: 1,2
            // Descending: 2,1
            // Sorted ret: 1,2
            if (e1 && !e2)
                return (NSComparisonResult)NSOrderedAscending;
            else if (!e1 && e2)
                return (NSComparisonResult)NSOrderedDescending;
            else if (!e1 && !e2)
                return (NSComparisonResult)NSOrderedSame;
            
            d1 = [[[o1 alarms] objectAtIndex:0] absoluteDate];
            d2 = [[[o2 alarms] objectAtIndex:0] absoluteDate];
            
            if ([d1 isEqualToDate:d2])
                return (NSComparisonResult)NSOrderedSame;
            else if (([d1 earlierDate:d2] == d1)) {
                if ([d1 timeIntervalSinceNow] > 0)
                    return (NSComparisonResult)NSOrderedDescending;
                else if ([d2 timeIntervalSinceNow] > 0)
                    return (NSComparisonResult)NSOrderedAscending;
                else
                    return (NSComparisonResult)NSOrderedSame;
            } else {
                if ([d2 timeIntervalSinceNow] > 0)
                    return (NSComparisonResult)NSOrderedAscending;
                else if ([d1 timeIntervalSinceNow] > 0)
                    return (NSComparisonResult)NSOrderedDescending;
                else
                    return (NSComparisonResult)NSOrderedSame;
            }
        }];
        _reminders = reminders;
        
        for (EKReminder *e in reminders) {
            NSDate *d = [[[e alarms] objectAtIndex:0] absoluteDate];
            NSString *t = [e title];
            NSMenuItem *i = [[NSMenuItem alloc] initWithTitle:t action:@selector(setEvent:) keyEquivalent:@""];
            [i setTarget:self];
            if (d != nil) {
                [pubMenu addItem:i];
                [eventItems setValue:d forKey:t];
            }
        }
        
        for (EKReminder *r in reminders) {
            NSDate *d = [[[r alarms] objectAtIndex:0] absoluteDate];
            title = r.title;
            if (d == nil)
                continue;
            date = d;
            dp.dateValue = date;
            return;
        }
    }];
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

-(NSString *)genStringFromDate:(NSDate *)theDate
{
    NSTimeInterval i = [theDate timeIntervalSinceNow];
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
    return toDisplay;
}

-(void)internalUpdate
{
    NSString *toDisplay = [self genStringFromDate:date];
    barItem.toolTip = [NSString stringWithFormat:@"%@: %@", title, toDisplay];
    toDisplay = [NSString stringWithFormat:@"Time until %@:\n%@", title, toDisplay];
    tf.stringValue = toDisplay;
    dispatch_async(dispatch_get_main_queue(), ^{[cdc updateTime:[date timeIntervalSinceNow]];});
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
