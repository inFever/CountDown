//
//  RBStatusBarHandler.h
//  CountDown
//
//  Created by Rachel Brindle on 4/23/13.
//  Copyright (c) 2013 Rachel Brindle. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RBPreferences.h"
#import "RBCountDownClock.h"

@interface RBStatusBarHandler : NSObject <NSWindowDelegate>
{
    RBCountDownClock *statusBarClock;
    NSMenuItem *showHide;
    NSMenuItem *bringFront;
    
    bool isWindowClosed;
    
    NSWindowController *aboutMe;
    RBPreferences *prefs;
    
    __block NSStatusItem *barItem;
}

@property (nonatomic, strong) NSWindow *window;
@property (nonatomic, strong) NSString *toolTip;

-(void)update:(NSTimeInterval)dt;

-(void)launchAboutMe:(id)sender;
-(void)launchPreferences:(id)sender;
-(void)showHide:(id)sender;
-(void)bringToFront:(id)sender;
-(void)quit:(id)sender;

@end
