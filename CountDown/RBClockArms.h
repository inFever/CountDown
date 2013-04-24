//
//  RBClockArms.h
//  CountDown
//
//  Created by Rachel Brindle on 4/23/13.
//  Copyright (c) 2013 Rachel Brindle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RBClockArms : NSView
{
    NSTimeInterval time;
}

@property (nonatomic) bool statusItem;

-(void)updateTime:(NSTimeInterval)newTime;

@end
