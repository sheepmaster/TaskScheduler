//
//  StatusChange.m
//  TaskScheduler
//
//  Created by Bernhard Bauer on 12.01.10.
//  Copyright 2010 Black Sheep Software. All rights reserved.
//

#import "StatusChange.h"


@implementation StatusChange

@dynamic task;
@dynamic date;
@dynamic status;

+ (StatusChange*)nextStatusChangeInContext:(NSManagedObjectContext*)context {
	NSFetchRequest* request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:@"StatusChange" inManagedObjectContext:context]];
	[request setFetchLimit:1];
	[request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]]];
	
	NSError* error = nil;
	NSArray* statusChanges = [context executeFetchRequest:request error:&error];
	StatusChange* change = nil;
	if (statusChanges) {
		if ([statusChanges count] > 0) {
			change = [statusChanges objectAtIndex:0];
		}
	} else {
		[NSApp presentError:error];
	}
	[request release];
	return change;
}

@end
