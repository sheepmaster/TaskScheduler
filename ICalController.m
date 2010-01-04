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

- (BOOL) copyNativeTask:(Task*)task toCalTask:(CalTask*)calTask {
	CalCalendarStore* store = [CalCalendarStore defaultCalendarStore];
	calTask.title = task.title;
	calTask.notes = task.notes;
	calTask.completedDate = task.completed;
	NSError* error = nil;
	bool ok = [store saveTask:calTask error:&error];
	if (!ok) {
		[NSApp presentError:error];
	}
	return ok;
}

- (BOOL) copyCalTask:(CalTask*)calTask toNativeTask:(Task*)task {
	task.title = calTask.title;
	task.notes = calTask.notes;
	task.completed = calTask.completedDate;
	return YES;
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
	for (Task* task in inserted) {
		CalTask* calTask = [CalTask task];
		calTask.calendar = [store calendarWithUID:[[NSUserDefaults standardUserDefaults] stringForKey:DefaultCalendarKey]];
		if ([self copyNativeTask:task toCalTask:calTask]) {
			task.taskUID = calTask.uid;
		} 
	}
	NSSet* updated = [userInfo objectForKey:NSUpdatedObjectsKey];
	for (Task* task in updated) {
		if (task.taskUID) {
			CalTask* calTask = [store taskWithUID:task.taskUID];
			if (calTask) {
				[self copyNativeTask:task toCalTask:calTask];
			}
		}
	}
	NSSet* deleted = [userInfo objectForKey:NSDeletedObjectsKey];
	for (Task* object in deleted) {
		if (object.taskUID) {
			CalTask* calTask = [store taskWithUID:object.taskUID];
			if (calTask) {
				NSError* error;
				if (![store removeTask:calTask error:&error]) {
					[NSApp presentError:error];
				}
			}
		}
	}
}

- (void)tasksChanged:(NSNotification*)notification {
	NSString* calendarUID = [[NSUserDefaults standardUserDefaults] stringForKey:DefaultCalendarKey];
	NSDictionary* userInfo = [notification userInfo];
	CalCalendarStore* calendarStore = [notification object];
	NSManagedObjectContext* context = [appDelegate managedObjectContext];
	for (NSString* uid in [userInfo objectForKey:CalInsertedRecordsKey]) {
		CalTask* calTask = [calendarStore taskWithUID:uid];
		if (calTask.calendar.uid == calendarUID) {
			Task* newTask = [[Task alloc] initWithManagedObjectContext:context];
			[self copyCalTask:calTask toNativeTask:newTask];
			newTask.taskUID = uid;
		}
	}
	for (NSString* uid in [userInfo objectForKey:CalUpdatedRecordsKey]) {
		CalTask* calTask = [calendarStore taskWithUID:uid];
		Task* task = [Task taskWithUID:uid inManagedObjectContext:context];
		[self copyCalTask:calTask toNativeTask:task];
	}
	for (NSString* uid in [userInfo objectForKey:CalDeletedRecordsKey]) {
		Task* task = [Task taskWithUID:uid inManagedObjectContext:context];
		[context deleteObject:task];
	}
}

@end
