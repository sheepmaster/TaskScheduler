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
	[statusChanges addObserver:self forKeyPath:@"arrangedObjects" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)changeDict context:(void *)dummy {
//	NSLog(@"change: %@", changeDict);
	StatusChange* change = [StatusChange nextStatusChangeInContext:context];
	if (![nextChange isEqualTo:change]) {
		NSLog(@"next change: %@", nextChange);
		[nextChange release];
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
		} else {
			nextChange = nil;
			nextChangeTimer = nil;
		}
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
