//
//  TaskCell.m
//  TaskScheduler
//
//  Created by Bernhard Bauer on 17.01.10.
//  Copyright 2010 Black Sheep Software. All rights reserved.
//

#import "TaskCell.h"

#import "Task.h"

@implementation TaskCell

@synthesize task;

- (void)drawInteriorWithFrame:(NSRect)theCellFrame inView:(NSView *)theControlView {
	NSString* title = task.title;
	
	[title drawInRect:theCellFrame withAttributes:nil];
}

@end
