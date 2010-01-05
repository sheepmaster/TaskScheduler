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

- (void)synchronize {
	CalCalendarStore* store = [CalCalendarStore defaultCalendarStore];
	NSManagedObjectContext* context = [appDelegate managedObjectContext];
	for (Task* task in [Task allTasksInManagedObjectContext:context]) {
		if (![store taskWithUID:task.taskUID]) {
			[self deletedCalTaskCorrespondingToNativeTask:task];
		}
	}
	
	NSPredicate* predicate = [CalCalendarStore taskPredicateWithCalendars:[NSArray arrayWithObject:[store calendarWithUID:[[NSUserDefaults standardUserDefaults] stringForKey:DefaultCalendarKey]]]];
	for (CalTask* calTask in [store tasksWithPredicate:predicate]) {
		Task* task = [Task taskWithUID:calTask.uid inManagedObjectContext:context];
		if (task == nil) {
			[self insertedCalTask:calTask];
		} else {
			[self copyCalTask:calTask toNativeTask:task];
		}
	}
}

- (BOOL) copyNativeTask:(Task*)task toCalTask:(CalTask*)calTask {
	CalCalendarStore* store = [CalCalendarStore defaultCalendarStore];
	calTask.title = task.title;
	calTask.notes = task.notes;
	calTask.completedDate = task.completed;
	calTask.dueDate = task.due;
	NSError* error = nil;
	bool ok = [store saveTask:calTask error:&error];
	if (!ok) {
		[NSApp presentError:error];
	}
	return ok;
}

- (BOOL) copyCalTask:(CalTask*)calTask toNativeTask:(Task*)task {
	NSCalendar* calendar = [NSCalendar autoupdatingCurrentCalendar];
	task.title = calTask.title;
	task.notes = calTask.notes;
	task.completed = calTask.completedDate;
//	task.due = calTask.dueDate;
	NSDateComponents* components = [calendar components:NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:task.due];
	task.due = [calendar dateByAddingComponents:components toDate:calTask.dueDate options:0];
	return YES;
}

- (void)deletedCalTaskCorrespondingToNativeTask:(Task*)task {
	NSManagedObjectContext* context = [appDelegate managedObjectContext];
	[context deleteObject:task];
}

- (void)insertedCalTask:(CalTask*)calTask {
	NSManagedObjectContext* context = [appDelegate managedObjectContext];
	Task* task = [[[Task alloc] initWithManagedObjectContext:context] autorelease];
	task.taskUID = calTask.uid;
	[self copyCalTask:calTask toNativeTask:task];
	[context insertObject:task];
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

	[self synchronize];
}

- (void)objectsDidChange:(NSNotification*)notification {
	CalCalendarStore* store = [CalCalendarStore defaultCalendarStore];
	NSDictionary* userInfo = [notification userInfo];
	NSEntityDescription* taskEntity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:[appDelegate managedObjectContext]];
	NSSet* inserted = [userInfo objectForKey:NSInsertedObjectsKey];
	for (id object in inserted) {
		if ([[object entity] isEqualTo:taskEntity]) {
			Task* task = object;
			if (!task.taskUID) {
				CalTask* calTask = [CalTask task];
				calTask.calendar = [store calendarWithUID:[[NSUserDefaults standardUserDefaults] stringForKey:DefaultCalendarKey]];
				if ([self copyNativeTask:task toCalTask:calTask]) {
					task.taskUID = calTask.uid;
				} 
			} else {
				NSLog(@"Inserted task with existing UID %@", task.taskUID);
			}
		}
	}
	NSSet* updated = [userInfo objectForKey:NSUpdatedObjectsKey];
	for (id object in updated) {
		if ([[object entity] isEqualTo:taskEntity]) {
			Task* task = object;
			if (task.taskUID) {
				CalTask* calTask = [store taskWithUID:task.taskUID];
				if (calTask) {
					[self copyNativeTask:task toCalTask:calTask];
				} else {
					NSLog(@"Updated task with invalid UID %@", task.taskUID);
				}
			} else {
				NSLog(@"Updated task without a UID");
			}
		}
	}
	NSSet* deleted = [userInfo objectForKey:NSDeletedObjectsKey];
	for (id object in deleted) {
		if ([[object entity] isEqualTo:taskEntity]) {
			Task* task = object;
			if (task.taskUID) {
				CalTask* calTask = [store taskWithUID:task.taskUID];
				if (calTask) {
					NSError* error;
					if (![store removeTask:calTask error:&error]) {
						[NSApp presentError:error];
					}
				} else {
					NSLog(@"Deleted task with invalid UID %@", task.taskUID);
				}
			} else {
				NSLog(@"Deleted task without a UID");
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
		if ([calTask.calendar.uid isEqualToString:calendarUID]) {
			[self insertedCalTask:calTask];
		}
	}
	for (NSString* uid in [userInfo objectForKey:CalUpdatedRecordsKey]) {
		CalTask* calTask = [calendarStore taskWithUID:uid];
		if (calTask) {
			if ([calTask.calendar.uid isEqualToString:calendarUID]) {
				Task* task = [Task taskWithUID:uid inManagedObjectContext:context];
				if (task) {
					[self copyCalTask:calTask toNativeTask:task];
				} else {
					NSLog(@"Updated CalTask with invalid UID %@", uid);
				}
			}
		} else {
			NSLog(@"Updated non-existing CalTask %@", uid);
		}
	}
	for (NSString* uid in [userInfo objectForKey:CalDeletedRecordsKey]) {
		Task* task = [Task taskWithUID:uid inManagedObjectContext:context];
		if (task) {
			[self deletedCalTaskCorrespondingToNativeTask:task];
		} else {
			NSLog(@"Deleted CalTask with invalid UID %@", uid);
		}
	}
}

@end
