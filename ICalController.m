//
//  ICalController.m
//  TaskScheduler
//
//  Created by Bernhard Bauer on 01.01.10.
//  Copyright 2010 Black Sheep Software. All rights reserved.
//

#import "ICalController.h"
#import <CalendarStore/CalendarStore.h>
#import "TaskScheduler_AppDelegate.h"
#import "Task.h"

static NSString* DefaultCalendarKey = @"DefaultCalendar";

@implementation ICalController

- (NSArray *)calendars {
	return [[CalCalendarStore defaultCalendarStore] calendars];
}

- (void) calendarsChanged:(NSNotification *)notification {
	[self willChangeValueForKey:@"calendars"];
	[self didChangeValueForKey:@"calendars"];
}

- (void)awakeFromNib {
	NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
	[center addObserver:self 
			   selector:@selector(objectsDidChange:) 
				   name:NSManagedObjectContextObjectsDidChangeNotification 
				 object:[appDelegate managedObjectContext]];
	[center addObserver:self
			   selector:@selector(tasksChanged:)
				   name:CalTasksChangedExternallyNotification
					 object:nil];
}

- (void)objectsDidChange:(NSNotification*)notification {
	CalCalendarStore* store = [CalCalendarStore defaultCalendarStore];
	NSDictionary* userInfo = [notification userInfo];
	NSSet* inserted = [userInfo objectForKey:NSInsertedObjectsKey];
	for (Task* object in inserted) {
		CalTask* task = [CalTask task];
		task.calendar = [store calendarWithUID:[[NSUserDefaults standardUserDefaults] stringForKey:DefaultCalendarKey]];
		task.title = object.title;
		task.notes = object.notes;
		NSError* error;
		if ([store saveTask:task error:&error]) {
			object.taskUID = task.uid;
		} else {
			[NSApp presentError:error];
		} 
	}
	NSSet* updated = [userInfo objectForKey:NSUpdatedObjectsKey];
	for (Task* object in updated) {
		if (object.taskUID) {
			CalTask* task = [store taskWithUID:object.taskUID];
			if (task) {
				task.title = object.title;
				task.notes = object.notes;
				NSError* error;
				if (![store saveTask:task error:&error]) {
					[NSApp presentError:error];
				}
			}
		}
	}
	NSSet* deleted = [userInfo objectForKey:NSDeletedObjectsKey];
	for (Task* object in deleted) {
		if (object.taskUID) {
			CalTask* task = [store taskWithUID:object.taskUID];
			if (task) {
				NSError* error;
				if (![store removeTask:task error:&error]) {
					[NSApp presentError:error];
				}
			}
		}
	}
}

- (void)tasksChanged:(NSNotification*)notification {
	NSDictionary* userInfo = [notification userInfo];
	CalCalendarStore* calendarStore = [notification object];
	NSManagedObjectContext* context = [appDelegate managedObjectContext];
	for (NSString* uid in [userInfo objectForKey:CalInsertedRecordsKey]) {
		CalTask* calTask = [calendarStore taskWithUID:uid];
		Task* newTask = [[Task alloc] initWithManagedObjectContext:context];
		newTask.title = calTask.title;
		newTask.notes = calTask.notes;
		newTask.taskUID = uid;
	}
	for (NSString* uid in [userInfo objectForKey:CalUpdatedRecordsKey]) {
		CalTask* calTask = [calendarStore taskWithUID:uid];
		Task* task = [Task taskWithUID:uid inManagedObjectContext:context];
		task.title = calTask.title;
		task.notes = calTask.notes;
	}
	for (NSString* uid in [userInfo objectForKey:CalDeletedRecordsKey]) {
		Task* task = [Task taskWithUID:uid inManagedObjectContext:context];
		[context deleteObject:task];
	}
}

@end
