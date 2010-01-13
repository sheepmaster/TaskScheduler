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
	[self setNextChange:nil];
}

	 
	 
- (void)setNextChange:(StatusChange*)change {
	NSLog(@"next change: %@", nextChange);
	[nextChange autorelease];
	[nextChangeDate autorelease];
	[nextChangeTimer invalidate];
	[nextChangeTimer release];
	if (change) {
		nextChange = [change retain];
		nextChangeTimer = [[NSTimer alloc] initWithFireDate:change.date 
												   interval:0 
													 target:self 
												   selector:@selector(executeStatusChange:) 
												   userInfo:nil 
													repeats:NO];
		nextChangeDate = [change.date retain];
	} else {
		nextChange = nil;
		nextChangeTimer = nil;
		nextChangeDate = [[NSDate distantFuture] retain];
	}
}

- (void)objectsDidChange:(NSNotification*)notification {
	NSDictionary* userInfo = [notification userInfo];
	NSSet* inserted = [userInfo objectForKey:NSInsertedObjectsKey];
//	StatusChange* candidate = nextChange;
	for (id object in inserted) {
		if ([object isKindOfClass:[StatusChange class]]) {
			StatusChange* change = object;
		}
	}
	NSSet* updated = [userInfo objectForKey:NSUpdatedObjectsKey];
	for (id object in updated) {
		if ([object isKindOfClass:[StatusChange class]]) {
			StatusChange* change = object;
//			if ([nextChangeDate
		}
	}
	NSSet* deleted = [userInfo objectForKey:NSDeletedObjectsKey];
	if ([deleted member:nextChange]) {
		
	}
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
