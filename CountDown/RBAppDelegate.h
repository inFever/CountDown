//
//  RBAppDelegate.h
//  CountDown
//
//  Created by Rachel Brindle on 3/21/13.
//  Copyright (c) 2013 Rachel Brindle. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RBCountDownClock.h"
#import "RBPreferences.h"


@interface RBAppDelegate : NSObject <NSApplicationDelegate, NSDatePickerCellDelegate>
{
    IBOutlet NSDatePicker *dp;
    IBOutlet NSTextField *tf;
    IBOutlet NSPopUpButton *pub;
    IBOutlet RBCountDownClock *cdc;
    IBOutlet NSButton *refreshButton;
    dispatch_queue_t queue;
    NSDate *date;
    NSString *title;
    NSThread *thread;
    
    NSDateFormatter *df;
    
    NSMenu *pubMenu;
    NSMutableDictionary *eventItems;
    
    RBCountDownClock *statusBarClock;
    NSMenuItem *showHide;
    
    RBPreferences *prefs;
    BOOL isWindowClosed;
    
    NSWindowController *aboutMe;
    
    __block NSStatusItem *barItem;
}

@property (assign) IBOutlet NSWindow *window;

-(void)updateThread;
-(IBAction)launchAboutMe:(id)sender;
-(IBAction)launchPreferences:(id)sender;

@end
