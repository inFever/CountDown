//
//  RBClockView.h
//  CountDown
//
//  Created by Rachel Brindle on 3/22/13.
//  Copyright (c) 2013 Rachel Brindle. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "RBClockArms.h"

@interface RBClockView : NSView
{
    RBClockArms *arms;
}

@property (nonatomic) bool statusItem;
@property (nonatomic, strong) NSColor *drawColor;

-(void)update:(NSTimeInterval)time;

@end
