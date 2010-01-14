//
//  StatusController.m
//  TaskScheduler
//
//  Created by Bernhard Bauer on 13.01.10.
//  Copyright 2010 Black Sheep Software. All rights reserved.
//

#import "StatusController.h"

#import "StatusChange.h"
#import "Task.h"
#import "TaskScheduler_AppDelegate.h"


@implementation StatusController

- (void)awakeFromNib {
	context = [appDelegate managedObjectContext];
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(objectsDidChange:) 
												 name:NSManagedObjectContextObjectsDidChangeNotification 
											   object:context];
	[self setNextChange:[StatusChange nextStatusChangeInContext:context]];
}

	 
	 
- (void)setNextChange:(StatusChange*)change {
	if (change == nextChange) {
		return;
	}
	[nextChange release];
	[nextChangeTimer invalidate];
	[nextChangeTimer release];
	nextChange = [change retain];
	nextChangeTimer = nil;
	if (change) {
		NSLog(@"next change: %@ %@ %@", change.task.title, change.status, change.date);
		nextChangeTimer = [[NSTimer alloc] initWithFireDate:change.date 
												   interval:0 
													 target:self 
												   selector:@selector(executeStatusChange:) 
												   userInfo:nil 
													repeats:NO];
		[[NSRunLoop mainRunLoop] addTimer:nextChangeTimer forMode:NSDefaultRunLoopMode];
	}
}

- (void)objectsDidChange:(NSNotification*)notification {
	NSDictionary* userInfo = [notification userInfo];
	NSSet* deleted = [userInfo objectForKey:NSDeletedObjectsKey];
	NSSet* updated = [userInfo objectForKey:NSUpdatedObjectsKey];
	StatusChange* candidate;
	if ([deleted member:nextChange] || [updated member:nextChange]) {
		candidate = nil;
	} else {
		candidate = nextChange;
	}
	
	NSSet* inserted = [userInfo objectForKey:NSInsertedObjectsKey];
	for (id object in [inserted setByAddingObjectsFromSet:updated]) {
		if ([object isKindOfClass:[StatusChange class]]) {
			StatusChange* change = object;
			if (!candidate || ([change.date compare:candidate.date] == NSOrderedAscending)) {
				candidate = change;
			}
		}
	}
	if (!candidate) {
		candidate = [StatusChange nextStatusChangeInContext:context];
	}
	[self setNextChange:candidate];
	
}

- (void)executeStatusChange:(NSTimer*)timer {
	NSString* status = nextChange.status;
	if ([status isEqualToString:@"start"]) {
		[nextChange.task updatePending];
	} else if ([status isEqualToString:@"completed"]) {
		[nextChange.task updateCompleted];
	} else if ([status isEqualToString:@"scheduled"]) {
		[nextChange.task updateActive];
	} else if ([status isEqualToString:@"due"]) {
		[nextChange.task updateOverdue];
	}
	[context deleteObject:nextChange];
}

@end
