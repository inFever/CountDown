//
//  RBLine.m
//  CountDown
//
//  Created by Rachel Brindle on 4/16/13.
//  Copyright (c) 2013 Rachel Brindle. All rights reserved.
//

#import "RBLine.h"

@implementation RBLine

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        _color = [NSColor blackColor];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSBezierPath *lines;
    
    NSPoint center = NSMakePoint(dirtyRect.size.width / 2.0, dirtyRect.size.height / 2.0);
    
    lines = [NSBezierPath bezierPath];
    [lines moveToPoint:center];
    [lines lineToPoint:NSMakePoint(center.x, 0)];
    [_color set];
    [lines stroke];
}

@end
