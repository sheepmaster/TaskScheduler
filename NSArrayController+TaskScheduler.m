//
//  NSArrayController+TaskScheduler.m
//  TaskScheduler
//
//  Created by Bernhard Bauer on 23.01.10.
//  Copyright 2010 Black Sheep Software. All rights reserved.
//

#import "NSArrayController+TaskScheduler.h"


@implementation NSArrayController(TaskScheduler)

- (NSUInteger)addNewObject {
	if (![self commitEditing]) {
		return -1;
	}
	
	id newObject = [self newObject];
	
	[self addObject:newObject];
	[newObject release];
	
	[self rearrangeObjects];
	
	NSArray* array = [self arrangedObjects];
	NSUInteger row = [array indexOfObject:newObject];
	
	return row;
}

@end
