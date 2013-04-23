//
//  RBPreferences.m
//  CountDown
//
//  Created by Rachel Brindle on 4/22/13.
//  Copyright (c) 2013 Rachel Brindle. All rights reserved.
//

#import "RBPreferences.h"

@implementation RBPreferences

-(id)init
{
    if ((self = [super init]) != nil) {
        wc = [[NSWindowController alloc] initWithWindowNibName:@"PreferencesWindow" owner:self];
        NSWindow *w = [wc window];
        [w setTitle:@"CountDown Preferences"];
        tf.delegate = self;
        
        [self updateKnownPrefs];
        
        for (NSColorWell *c in @[week, day, hour, minute, second]) {
            [c setTarget:self];
            [c setAction:@selector(changePref:)];
        }
    }
    return self;
}

-(void)controlTextDidEndEditing:(NSNotification *)obj
{
    [self changePref:tf];
}

-(void)updateKnownPrefs
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    tf.stringValue = [ud stringForKey:TITLE_KEY];
    NSData *data;
    data = [ud objectForKey:WEEK_KEY];
    week.color = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    data = [ud objectForKey:DAY_KEY];
    day.color = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    data = [ud objectForKey:HOUR_KEY];
    hour.color = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    data = [ud objectForKey:MINUTE_KEY];
    minute.color = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    data = [ud objectForKey:SECOND_KEY];
    second.color = [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

-(void)showWindow
{
    [wc.window makeKeyAndOrderFront:nil];
}

-(void)changePref:(id)sender
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *s = nil;
    if (sender == week)
        s = WEEK_KEY;
    else if (sender == day)
        s = DAY_KEY;
    else if (sender == hour)
        s = HOUR_KEY;
    else if (sender == minute)
        s = MINUTE_KEY;
    else if (sender == second)
        s = SECOND_KEY;
    else if (sender == tf)
        [ud setObject:tf.stringValue forKey:TITLE_KEY];
    if (!s)
        return;
    NSColor *c = [sender color];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:c];
    [ud setObject:data forKey:s];
}

@end
