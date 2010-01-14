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
#import "PreferencesController.h"

static NSString* DefaultCalendarKey = @"DefaultCalendar";
static NSString* DefaultScheduleCalendarKey = @"DefaultScheduleCalendar";

@implementation ICalController

- (void)awakeFromNib {
	calendarStore = [CalCalendarStore defaultCalendarStore];
	context = [appDelegate managedObjectContext];	
	
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSString* defaultCalendarUID = [defaults stringForKey:DefaultCalendarKey];
	if (!defaultCalendarUID || ![calendarStore calendarWithUID:defaultCalendarUID]) {
		[defaults setObject:[[[calendarStore calendars] objectAtIndex:0] uid] forKey:DefaultCalendarKey];
	}
	NSString* defaultScheduleUID = [defaults stringForKey:DefaultScheduleCalendarKey];
	if (!defaultScheduleUID || ![calendarStore calendarWithUID:defaultScheduleUID]) {
		[defaults setObject:[[[calendarStore calendars] objectAtIndex:0] uid] forKey:DefaultScheduleCalendarKey];
	}
	
	
	NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
	[center addObserver:self 
			   selector:@selector(objectsDidChange:) 
				   name:NSManagedObjectContextObjectsDidChangeNotification 
				 object:context];
	[center addObserver:self
			   selector:@selector(tasksChanged:)
				   name:CalTasksChangedExternallyNotification
				 object:nil];
	[center addObserver:self
			   selector:@selector(eventsChanged:)
				   name:CalEventsChangedExternallyNotification
				 object:nil];
	
	[self synchronize];
}

- (NSArray *)calendars {
	return [[CalCalendarStore defaultCalendarStore] calendars];
}

- (void) calendarsChanged:(NSNotification *)notification {
	[self willChangeValueForKey:@"calendars"];
	[self didChangeValueForKey:@"calendars"];
}

- (void)synchronize {
	for (Task* task in [Task allTasksInManagedObjectContext:context]) {
		if (task.taskUID) {
			CalTask* calTask = [calendarStore taskWithUID:task.taskUID];
			if (calTask) {
				[self copyCalTask:calTask toNativeTask:task];
			} else {
				[self deletedCalTaskCorrespondingToNativeTask:task];
			}
		}
		if (task.eventUID) {
			CalEvent* event = [calendarStore eventWithUID:task.eventUID occurrence:nil];
			if (event) {
				[self copyCalEvent:event toTask:task];
			} else {
				[self eventDeletedForTask:task];
			}
		}
	}
	
	NSPredicate* predicate = [CalCalendarStore taskPredicateWithCalendars:[NSArray arrayWithObject:[calendarStore calendarWithUID:[[NSUserDefaults standardUserDefaults] stringForKey:DefaultCalendarKey]]]];
	for (CalTask* calTask in [calendarStore tasksWithPredicate:predicate]) {
		Task* task = [Task taskWithTaskUID:calTask.uid inManagedObjectContext:context];
		if (task == nil) {
			[self insertedCalTask:calTask];
		}
	}
}

- (BOOL)copyNativeTask:(Task*)task toEvent:(CalEvent*)event {
	event.startDate = task.scheduledDate;
	event.endDate = [task.scheduledDate dateByAddingTimeInterval:[task.duration doubleValue]];
	event.title = task.title;
	event.notes = task.notes;
	//				scheduledEvent.location = task.location;
	NSError* error = nil;
	if (![calendarStore saveEvent:event span:CalSpanAllEvents error:&error]) {
		[NSApp presentError:error];
		return NO;
	}
	return YES;
}

- (BOOL)synchronizeScheduleForTask:(Task*)task {
	if (task.scheduledDate) {
		CalEvent* event;
		if (task.eventUID) {
			event = [calendarStore eventWithUID:task.eventUID occurrence:nil];
			if (event) {
				if (![self copyNativeTask:task toEvent:event]) {
					return NO;
				}
			} else {
				NSLog(@"Event %@ not found", task.eventUID);
				task.eventUID = nil;
			}
		} else if ([defaults boolForKey:CreateEventForScheduledTaskKey]) {
			[self createEventForTask:task];
		}
	} else {
		if (task.eventUID) {
			CalEvent* event = [calendarStore eventWithUID:task.eventUID occurrence:nil];
			if (event) {
				NSError* error = nil;
				if (![calendarStore removeEvent:event span:CalSpanAllEvents error:&error]) {
					[NSApp presentError:error];
					return NO;
				}
			} else {
				NSLog(@"Scheduled task %@ not found", task.eventUID);
			}
			task.eventUID = nil;
		}
	}
	return YES;
}

- (BOOL)copyNativeTask:(Task*)task toCalTask:(CalTask*)calTask {
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

	calTask.title = task.title;
	calTask.notes = task.notes;
	calTask.completedDate = task.completedDate;
	calTask.dueDate = task.dueDate;
	NSError* error = nil;
	if (![calendarStore saveTask:calTask error:&error]) {
		[NSApp presentError:error];
		return NO;
	}
	
	return YES;
}

static inline BOOL equals(id a, id b) {
	return (a == b) || [a isEqual:b];
}

- (void) copyCalTask:(CalTask*)calTask toNativeTask:(Task*)task {
	NSCalendar* calendar = [NSCalendar autoupdatingCurrentCalendar];
	if (!equals(task.title, calTask.title)) {
		task.title = calTask.title;
	}
	if (!equals(task.notes, calTask.notes)) {
		task.notes = calTask.notes;
	}
	if (!equals(task.completedDate, calTask.completedDate)) {
		task.completedDate = calTask.completedDate;
	}
//	task.due = calTask.dueDate;
	NSDate* newDate;
	if (task.dueDate && calTask.dueDate) {
		NSDateComponents* components = [calendar components:NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:task.dueDate];
		newDate = [calendar dateByAddingComponents:components toDate:calTask.dueDate options:0];
	} else {
		newDate = calTask.dueDate;
	}
	if (!equals(newDate, task.dueDate)) {
		task.dueDate = newDate;
	}
}

- (void) copyCalEvent:(CalEvent*)event toTask:(Task*)task {
	if (!equals(task.scheduledDate, event.startDate)) {
		task.scheduledDate = event.startDate;
	}
	NSNumber* newDuration = [NSNumber numberWithDouble:[event.endDate timeIntervalSinceDate:event.startDate]];
	if (!equals(task.duration, newDuration)) {
		task.duration = newDuration;
	}
}

- (void)createCalTaskForTask:(Task*)task {
	CalTask* calTask = [CalTask task];
	calTask.calendar = [calendarStore calendarWithUID:[[NSUserDefaults standardUserDefaults] stringForKey:DefaultCalendarKey]];
	if ([self copyNativeTask:task toCalTask:calTask]) {
		task.taskUID = calTask.uid;
	}
}

- (void)createEventForTask:(Task*)task {
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	CalEvent* event = [CalEvent event];
	NSString* calendarUID = [defaults boolForKey:UseCustomScheduleCalendarKey] ? [defaults objectForKey:DefaultScheduleCalendarKey] : [defaults objectForKey:DefaultCalendarKey];
	event.calendar = [calendarStore calendarWithUID:calendarUID];
	if ([self copyNativeTask:task toEvent:event]) {
		task.eventUID = event.uid;
	}
}

- (void) eventDeletedForTask:(Task*)task {
	NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
	[center removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:context];

	if ([[NSUserDefaults standardUserDefaults] boolForKey:UnscheduleTaskForDeletedEventKey]) {
		task.scheduledDate = nil;
	}
	task.eventUID = nil;
	[context processPendingChanges];
	
	[center addObserver:self 
			   selector:@selector(objectsDidChange:) 
				   name:NSManagedObjectContextObjectsDidChangeNotification 
				 object:context];
} 

- (void) deleteEventForTask:(Task*)task {
	if (task.eventUID) {
		CalEvent* event = [calendarStore eventWithUID:task.eventUID occurrence:nil];
		if (event) {
			NSError* error;
			if (![calendarStore removeEvent:event span:CalSpanAllEvents error:&error]) {
				[NSApp presentError:error];
			}
		} else {
			NSLog(@"Deleted task with invalid event UID %@", task.eventUID);
		}
	}
}


- (void)deletedCalTaskCorrespondingToNativeTask:(Task*)task {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:DeleteTaskForDeletedCalTaskKey]) {
//		NSLog(@"disabling objectsdidchange notifications for deleting task");
		NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
		[center removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:context];

		[self deleteEventForTask:task];
		[context deleteObject:task];
		[context processPendingChanges];
		
		[center addObserver:self 
				   selector:@selector(objectsDidChange:) 
					   name:NSManagedObjectContextObjectsDidChangeNotification 
					 object:context];
//		NSLog(@"re-enabling objectsdidchange notifications for deleting task");
	} else {
		task.taskUID = nil;
	}
}

- (void)insertedCalTask:(CalTask*)calTask {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:CreateTaskForNewCalTaskKey]) {
//		NSLog(@"disabling objectsdidchange notifications for inserting task");
		NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
		[center removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:context];
		
		Task* task = [[Task alloc] initWithManagedObjectContext:context];
		task.taskUID = calTask.uid;
		[self copyCalTask:calTask toNativeTask:task];
		[context insertObject:task];
		[context processPendingChanges];
		[task release];
		
		[center addObserver:self 
				   selector:@selector(objectsDidChange:) 
					   name:NSManagedObjectContextObjectsDidChangeNotification 
					 object:context];
//		NSLog(@"re-enabling objectsdidchange notifications for inserting task");
	}
}

- (void)insertedTask:(Task*)task {
	if (!task.taskUID) {
		if ([[NSUserDefaults standardUserDefaults] boolForKey:CreateCalTaskForNewTaskKey]) {
			[self createCalTaskForTask:task];
		}
	} else {
		NSLog(@"Inserted task with existing UID %@", task.taskUID);
	}
	[self synchronizeScheduleForTask:task];
}

- (void)updatedTask:(Task*)task {
	if (task.taskUID) {
		CalTask* calTask = [calendarStore taskWithUID:task.taskUID];
		if (calTask) {
			[self copyNativeTask:task toCalTask:calTask];
		}
	}
	[self synchronizeScheduleForTask:task];
}

- (void)deletedTask:(Task*)task {
	if (task.taskUID) {
		CalTask* calTask = [calendarStore taskWithUID:task.taskUID];
		if (calTask) {
			NSError* error;
			if (![calendarStore removeTask:calTask error:&error]) {
				[NSApp presentError:error];
			}
		}
	}
	[self deleteEventForTask:task];
}

- (void)objectsDidChange:(NSNotification*)notification {
	NSDictionary* userInfo = [notification userInfo];
	NSSet* inserted = [userInfo objectForKey:NSInsertedObjectsKey];
	for (id object in inserted) {
		if ([object isKindOfClass:[Task class]]) {
			[self insertedTask:object];
		}
	}
	NSSet* updated = [userInfo objectForKey:NSUpdatedObjectsKey];
	for (id object in updated) {
		if ([object isKindOfClass:[Task class]]) {
			[self updatedTask:object];
		}
	}
	NSSet* deleted = [userInfo objectForKey:NSDeletedObjectsKey];
	for (id object in deleted) {
		if ([object isKindOfClass:[Task class]]) {
			[self deletedTask:object];
		}
	}
}

- (void)tasksChanged:(NSNotification*)notification {
	NSDictionary* userInfo = [notification userInfo];
	for (NSString* uid in [userInfo objectForKey:CalInsertedRecordsKey]) {
		CalTask* calTask = [calendarStore taskWithUID:uid];
		if ([calTask.calendar.uid isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:DefaultCalendarKey]]) {
			[self insertedCalTask:calTask];
		}
	}
	for (NSString* uid in [userInfo objectForKey:CalUpdatedRecordsKey]) {
		CalTask* calTask = [calendarStore taskWithUID:uid];
		if (calTask) {
			Task* task = [Task taskWithTaskUID:uid inManagedObjectContext:context];
			if (task) {
				[self copyCalTask:calTask toNativeTask:task];
			}
		} else {
			NSLog(@"Updated non-existing CalTask %@", uid);
		}
	}
	for (NSString* uid in [userInfo objectForKey:CalDeletedRecordsKey]) {
		Task* task = [Task taskWithTaskUID:uid inManagedObjectContext:context];
		if (task) {
			[self deletedCalTaskCorrespondingToNativeTask:task];
		}
	}
}

- (void)eventsChanged:(NSNotification*)notification {
	NSDictionary* userInfo = [notification userInfo];
	NSPredicate* predicateTemplate = [NSPredicate predicateWithFormat:@"eventUID == $UID"];

	for (NSString* uid in [userInfo objectForKey:CalUpdatedRecordsKey]) {
		CalEvent* event = [calendarStore eventWithUID:uid occurrence:nil];
		if (event) {
			Task* task = [Task taskMatchingPredicate:[predicateTemplate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObject:uid forKey:@"UID"]] inManagedObjectContext:context];
			if (task) {
				[self copyCalEvent:event toTask:task];
			}
		} else {
			NSLog(@"Updated non-existing CalEvent %@", uid);
		}
	}
	for (NSString* uid in [userInfo objectForKey:CalDeletedRecordsKey]) {
		Task* task = [Task taskMatchingPredicate:[predicateTemplate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObject:uid forKey:@"UID"]] inManagedObjectContext:context];
		if (task) {
			[self eventDeletedForTask:task];
		}
	}
}

@end
