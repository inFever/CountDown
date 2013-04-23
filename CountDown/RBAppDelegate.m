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
    
    [refreshButton setAction:@selector(retrieveEvents)];
    [refreshButton setTarget:self];
    [refreshButton sendActionOn:NSLeftMouseUpMask];
    
    _window.delegate = self;
    isWindowClosed = NO;
    
    title = [[NSUserDefaults standardUserDefaults] stringForKey:TITLE_KEY];
    if (title == nil)
        title = @"Unknown";
    date = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:DATE_KEY];
    if (date == nil)
        date = [NSDate dateWithString:@"2013-05-14 08:45:00 -0700"];
    dp.dateValue = date;
    dp.delegate = self;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(updateThread) object:nil];
    [thread start];
        
#ifdef TARGET_OS_MAC
    [_window setReleasedWhenClosed:NO];
    
    NSStatusBar *bar = [NSStatusBar systemStatusBar];
    barItem = [bar statusItemWithLength:NSVariableStatusItemLength];
    statusBarClock = [[RBCountDownClock alloc] initWithFrame:NSMakeRect(0, 0, [bar thickness] + 6, [bar thickness] - 10) statusItem:YES];
    //__block RBAppDelegate *s = self;
    
    NSMenu *statusBarMenu = [[NSMenu alloc] initWithTitle:@""];
    NSMenuItem *about = [[NSMenuItem alloc] initWithTitle:@"About CountDown" action:@selector(launchAboutMe:) keyEquivalent:@""];
    [about setTarget:self];
    NSMenuItem *preferences = [[NSMenuItem alloc] initWithTitle:@"Preferences..." action:@selector(launchPreferences:) keyEquivalent:@""];
    [preferences setTarget:self];
    showHide = [[NSMenuItem alloc] initWithTitle:@"Hide Window" action:@selector(showHide:) keyEquivalent:@""];
    [showHide setTarget:self];
    NSMenuItem *quit = [[NSMenuItem alloc] initWithTitle:@"Quit CountDown" action:@selector(quit:) keyEquivalent:@"q"];
    [quit setTarget:self];
    [statusBarMenu addItem:about];
    [statusBarMenu addItem:preferences];
    [statusBarMenu addItem:[NSMenuItem separatorItem]];
    [statusBarMenu addItem:showHide];
    [statusBarMenu addItem:[NSMenuItem separatorItem]];
    [statusBarMenu addItem:quit];
    [statusBarClock setMenu:statusBarMenu];
    
    statusBarClock.statusItem = barItem;
    
    /*
    [statusBarClock setOnClick:^{
        [barItem popUpStatusItemMenu:statusBarMenu];
    }];
     */
    
    [barItem setView:statusBarClock];
    [barItem setTitle:@"CountDown"];
    [barItem setAction:@selector(showWindow)];
    [barItem setTarget:self];
    [barItem sendActionOn:NSLeftMouseUpMask];
#endif
}

-(void)windowWillClose:(NSNotification *)notification
{
    NSWindow *w = notification.object;
    if (w == _window) {
        isWindowClosed = YES;
        [showHide setTitle:@"Show Window"];
    }
}

-(void)quit:(id)sender
{
    [NSApp performSelector:@selector(terminate:) withObject:nil afterDelay:0.0];
}

-(void)showHide:(id)sender
{
    if (!isWindowClosed) {
        [_window close];
        isWindowClosed = YES;
        [showHide setTitle:@"Show Window"];
    } else {
        [self showWindow];
        [showHide setTitle:@"Hide Window"];
    }
    
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

-(IBAction)launchPreferences:(id)sender
{
    if (!prefs)
        prefs = [[RBPreferences alloc] init];
    [prefs updateKnownPrefs];
    [prefs showWindow];
}

-(IBAction)launchAboutMe:(id)sender
{
    aboutMe = [[NSWindowController alloc] initWithWindowNibName:@"AboutMe"];
    [[aboutMe window] setLevel:NSFloatingWindowLevel];
}

-(void)showWindow
{
    [_window makeKeyAndOrderFront:nil];
    isWindowClosed = NO;
}

-(void)setEvent:(id)sender
{
    NSMenuItem *i = (NSMenuItem *)sender;
    NSString *key = [i title];
    EKCalendarItem *e = (EKCalendarItem *)[eventItems objectForKey:key];
    NSDate *now = [NSDate date];
    for (EKAlarm *a in [e alarms]) {
        if ([[a absoluteDate] earlierDate:now] != now)
            continue;
        date = [a absoluteDate];
        break;
    }

    title = [e title];
    
    [[NSUserDefaults standardUserDefaults] setObject:title forKey:TITLE_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:DATE_KEY];
    
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
        NSDate *now = [NSDate date];
        for (EKEvent *e in events) {
            NSDate *d = nil;
            for (EKAlarm *a in [e alarms]) {
                if ([[a absoluteDate] earlierDate:now] != now)
                    continue;
                d = [a absoluteDate];
                break;
            }
            if (d == nil)
                continue;
            NSString *t = [e title];
            NSString *s = [NSString stringWithFormat:@"%@ - %@", t, d];
            if ([eventItems objectForKey:s] != nil)
                continue;
            NSMenuItem *i = [[NSMenuItem alloc] initWithTitle:s action:@selector(setEvent:) keyEquivalent:@""];
            [i setTarget:self];
            if (d != nil) {
                [pubMenu addItem:i];
                [eventItems setValue:e forKey:s];
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
        NSDate *now = [NSDate date];
        for (EKReminder *e in reminders) {
            NSDate *d = nil;
            for (EKAlarm *a in [e alarms]) {
                if ([[a absoluteDate] earlierDate:now] != now)
                    continue;
                d = [a absoluteDate];
                break;
            }
            if (d == nil)
                continue;
            NSString *t = [e title];
            NSString *s = [NSString stringWithFormat:@"%@ - %@", t, d];
            if ([eventItems objectForKey:s] != nil)
                continue;
            NSMenuItem *i = [[NSMenuItem alloc] initWithTitle:s action:@selector(setEvent:) keyEquivalent:@""];
            [i setTarget:self];
            if (d != nil) {
                [pubMenu addItem:i];
                [eventItems setValue:e forKey:s];
            }
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
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:DATE_KEY];
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
    title = [[NSUserDefaults standardUserDefaults] stringForKey:TITLE_KEY];
    barItem.toolTip = [NSString stringWithFormat:@"%@: %@", title, toDisplay];
    toDisplay = [NSString stringWithFormat:@"Time until %@:\n%@", title, toDisplay];
    tf.stringValue = toDisplay;
    dispatch_async(dispatch_get_main_queue(), ^{
        [cdc updateTime:[date timeIntervalSinceNow]];
        [statusBarClock updateTime:[date timeIntervalSinceNow]];
    });
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
