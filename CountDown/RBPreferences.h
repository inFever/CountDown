//
//  RBPreferences.h
//  CountDown
//
//  Created by Rachel Brindle on 4/22/13.
//  Copyright (c) 2013 Rachel Brindle. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DATE_KEY @"RBDate"
#define TITLE_KEY @"RBTitle"

#define WEEK_KEY   @"week_color"
#define DAY_KEY    @"day_color"
#define HOUR_KEY   @"hour_color"
#define MINUTE_KEY @"minute_color"
#define SECOND_KEY @"second_color"

@interface RBPreferences : NSObject <NSTextFieldDelegate>
{
    NSWindowController *wc;
    IBOutlet NSTextField *tf;
    IBOutlet NSColorWell *week, *day, *hour, *minute, *second;
}

-(void)changePref:(id)sender;
-(void)showWindow;
-(void)updateKnownPrefs;

@end
