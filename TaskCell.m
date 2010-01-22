//
//  TaskCell.m
//  TaskScheduler
//
//  Created by Bernhard Bauer on 17.01.10.
//  Copyright 2010 Black Sheep Software. All rights reserved.
//

#import "TaskCell.h"

#import "Task.h"
#import "NSMutableAttributedString+TaskScheduler.h"

@implementation TaskCell

@synthesize task;

- (void)drawInteriorWithFrame:(NSRect)theCellFrame inView:(NSView *)theControlView {
	if (task.title) {
		NSFont* font = [self font];
		NSDictionary* dict = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
		NSMutableAttributedString* string = [[NSMutableAttributedString alloc] initWithString:task.title attributes:dict];
		if (task.notes) {
			[string appendString:@" "];
			dict = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, [NSColor disabledControlTextColor], NSForegroundColorAttributeName, [NSColor whiteColor], NSBackgroundColorAttributeName, nil];
			[string appendString:task.notes withAttributes:dict];
		}
		
		[string drawInRect:theCellFrame];
	}
}

@end
