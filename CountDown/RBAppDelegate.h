//
//  RBAppDelegate.h
//  CountDown
//
//  Created by Rachel Brindle on 3/21/13.
//  Copyright (c) 2013 Rachel Brindle. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RBCountDownClock.h"

@interface RBAppDelegate : NSObject <NSApplicationDelegate, NSDatePickerCellDelegate>
{
    IBOutlet NSDatePicker *dp;
    IBOutlet NSTextField *tf;
    IBOutlet NSPopUpButton *pub;
    IBOutlet RBCountDownClock *cdc;
    dispatch_queue_t queue;
    NSDate *date;
    NSString *title;
    NSThread *thread;
    
    NSDateFormatter *df;
    
    NSMenu *pubMenu;
    NSArray *_reminders;
    NSArray *_events;
    NSMutableDictionary *eventItems;
    
    
    NSStatusItem *barItem;
}

@property (assign) IBOutlet NSWindow *window;

-(void)updateThread;

@end
