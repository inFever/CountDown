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

#import "RBStatusBarHandler.h"


@interface RBAppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate, NSDatePickerCellDelegate>
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
            
    NSMenu *pubMenu;
    NSMutableDictionary *eventItems;
    
    RBStatusBarHandler *statusBar;
}

@property (assign) IBOutlet NSWindow *window;

-(void)updateThread;

@end
