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
	NSString* title = task.title;
	if (!title) {
		title = @"";
	}
	NSFont* font = [self font];
	NSDictionary* dict = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
	NSMutableAttributedString* string = [[NSMutableAttributedString alloc] initWithString:title attributes:dict];
	NSMutableArray* labels = [NSMutableArray array];
	if ([task.completed boolValue]) {
		[labels addObject:@" completed "];
	} else {
		if ([task.pending boolValue]) {
			[labels addObject:@" pending "];
		}
		if ([task.inactive boolValue]) {
			[labels addObject:@" inactive "];
		}
		if ([task.active boolValue]) {
			[labels addObject:@" active "];
		}
		if ([task.overdue boolValue]) {
			[labels addObject:@" overdue "];
		}
	}
	for (NSString* label in labels) {
		[string appendString:@" "];
		float miniSize = [NSFont systemFontSizeForControlSize:NSMiniControlSize];
		NSFont* smallFont = [NSFont fontWithDescriptor:[font fontDescriptor] size:miniSize];
		float baselineOffset = ([font ascender]-[smallFont ascender]-[font descender]+[smallFont descender])/2;
		NSColor* color = [NSColor colorWithDeviceRed:1.0 green:0.0 blue:0.0 alpha:0.1];
		dict = [NSDictionary dictionaryWithObjectsAndKeys:smallFont, NSFontAttributeName, [NSColor redColor], NSForegroundColorAttributeName, [NSNumber numberWithFloat:baselineOffset], NSBaselineOffsetAttributeName, color, NSBackgroundColorAttributeName, nil];
		[string appendString:label withAttributes:dict];
	}
	if (task.notes) {
		[string appendString:@" "];
		dict = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, [NSColor disabledControlTextColor], NSForegroundColorAttributeName, nil];
		[string appendString:task.notes withAttributes:dict];
	}
	
	[string drawInRect:theCellFrame];
}

@end
