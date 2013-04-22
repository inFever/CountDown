//
//  RBEventPicker.h
//  CountDown
//
//  Created by Rachel Brindle on 4/22/13.
//  Copyright (c) 2013 Rachel Brindle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RBEventPicker : NSObject <NSWindowDelegate>
{
}

@property (nonatomic, strong) NSArray *events;
@property (nonatomic, strong) NSArray *reminders;

@end
