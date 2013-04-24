//
//  RBStatusBarHandler.m
//  CountDown
//
//  Created by Rachel Brindle on 4/23/13.
//  Copyright (c) 2013 Rachel Brindle. All rights reserved.
//

#import "RBStatusBarHandler.h"

@implementation RBStatusBarHandler

-(id)init
{
    if ((self = [super init]) != nil) {
        [self commonInit];
    }
    return self;
}

-(void)commonInit
{
    NSStatusBar *bar = [NSStatusBar systemStatusBar];
    barItem = [bar statusItemWithLength:NSVariableStatusItemLength];
    statusBarClock = [[RBCountDownClock alloc] initWithFrame:NSMakeRect(0, 0, [bar thickness] *1.25, [bar thickness]) statusItem:YES];

    NSMenu *statusBarMenu = [[NSMenu alloc] initWithTitle:@""];
    NSMenuItem *about = [[NSMenuItem alloc] initWithTitle:@"About CountDown" action:@selector(launchAboutMe:) keyEquivalent:@""];
    [about setTarget:self];
    NSMenuItem *preferences = [[NSMenuItem alloc] initWithTitle:@"Preferences..." action:@selector(launchPreferences:) keyEquivalent:@""];
    [preferences setTarget:self];
    showHide = [[NSMenuItem alloc] initWithTitle:@"Show Window" action:@selector(showHide:) keyEquivalent:@""];
    [showHide setTarget:self];
    bringFront = [[NSMenuItem alloc] initWithTitle:@"Bring to Front" action:@selector(bringToFront:) keyEquivalent:@""];
    [bringFront setTarget:self];
    [bringFront setHidden:YES];
    NSMenuItem *quit = [[NSMenuItem alloc] initWithTitle:@"Quit CountDown" action:@selector(quit:) keyEquivalent:@"q"];
    [quit setTarget:self];
    [statusBarMenu addItem:about];
    [statusBarMenu addItem:preferences];
    [statusBarMenu addItem:[NSMenuItem separatorItem]];
    [statusBarMenu addItem:showHide];
    [statusBarMenu addItem:bringFront];
    [statusBarMenu addItem:[NSMenuItem separatorItem]];
    [statusBarMenu addItem:quit];
    [statusBarClock setMenu:statusBarMenu];
    
    statusBarClock.statusItem = barItem;
    
    [barItem setView:statusBarClock];
    [barItem setTitle:@"CountDown"];
    [barItem setAction:@selector(showWindow)];
    [barItem setTarget:self];
    [barItem sendActionOn:NSLeftMouseUpMask];
    
    isWindowClosed = YES;
}

-(void)update:(NSTimeInterval)dt
{
    statusBarClock.toolTip = _toolTip;
    [statusBarClock updateTime:dt];
}

-(void)launchAboutMe:(id)sender
{
    aboutMe = [[NSWindowController alloc] initWithWindowNibName:@"AboutMe"];
    [[aboutMe window] setLevel:NSFloatingWindowLevel];
    [[aboutMe window] makeKeyAndOrderFront:nil];
}

-(void)launchPreferences:(id)sender
{
    if (!prefs)
        prefs = [[RBPreferences alloc] init];
    [prefs updateKnownPrefs];
    [prefs showWindow];
}

-(void)showHide:(id)sender
{
    if (!isWindowClosed) {
        [_window close];
        [self closeWindow];
    } else {
        [self showWindow];
    }
}

-(void)bringToFront:(id)sender
{
    [NSApp activateIgnoringOtherApps:YES];
}

-(void)quit:(id)sender
{
    [NSApp performSelector:@selector(terminate:) withObject:nil afterDelay:0.0];
}

-(void)closeWindow
{
    isWindowClosed = YES;
    [showHide setTitle:@"Show Window"];
    [bringFront setHidden:YES];
}

-(void)showWindow
{
    [_window makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES];
    isWindowClosed = NO;
    [bringFront setHidden:NO];
    [showHide setTitle:@"Hide Window"];
}

@end
