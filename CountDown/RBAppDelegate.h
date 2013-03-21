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
    IBOutlet RBCountDownClock *cdc;
    NSDate *date;
    NSThread *thread;
}

@property (assign) IBOutlet NSWindow *window;

-(void)updateThread;
//-(IBAction)DateChanged:(id)sender;

@end
