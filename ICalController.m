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

- (NSPredicate*)isInDefaultCalendarPredicate {
	return [CalCalendarStore taskPredicateWithCalendars:[NSArray arrayWithObject:[calendarStore calendarWithUID:[[NSUserDefaults standardUserDefaults] stringForKey:DefaultCalendarKey]]]];
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
		} else {
			NSLog(@"Task %@ has no task UID", task);
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
	
	for (CalTask* calTask in [calendarStore tasksWithPredicate:[self isInDefaultCalendarPredicate]]) {
		Task* task = [Task taskWithTaskUID:calTask.uid inManagedObjectContext:context];
		if (task == nil) {
			[self insertedCalTask:calTask];
		}
	}
}

- (BOOL) copyNativeTask:(Task*)task toCalTask:(CalTask*)calTask {
	calTask.title = task.title;
	calTask.notes = task.notes;
	calTask.completedDate = task.completedDate;
	calTask.dueDate = task.dueDate;
	NSError* error = nil;
	if (![calendarStore saveTask:calTask error:&error]) {
		[NSApp presentError:error];
		return NO;
	}
	
	if (task.scheduledDate) {
		CalEvent* event;
		if (task.eventUID) {
			event = [calendarStore eventWithUID:task.eventUID occurrence:nil];
		} else {
			event = [CalEvent event];
			event.calendar = [calendarStore calendarWithUID:[[NSUserDefaults standardUserDefaults] stringForKey:DefaultCalendarKey]];
			task.eventUID = event.uid;
		}
		if (event) {
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
		} else {
			NSLog(@"Event %@ not found");
			task.eventUID = nil;
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
				NSLog(@"Scheduled task %@ not found");
				task.eventUID = nil;
			}
		}
	}
	
	return YES;
}

static BOOL equals(id a, id b) {
	if (a) {
		NSLog(@"%@", a);
	}
	return (a == nil) && (b == nil);
//	return (a == b) || [a isEqual:b];
//	return NO;
}

- (BOOL) copyCalTask:(CalTask*)calTask toNativeTask:(Task*)task {
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
	return YES;
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

- (void) eventDeletedForTask:(Task*)task {
	task.scheduledDate = nil;
	task.eventUID = nil;
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
	[self deleteEventForTask:task];
	[context deleteObject:task];
}

- (void)insertedCalTask:(CalTask*)calTask {
	Task* task = [[[Task alloc] initWithManagedObjectContext:context] autorelease];
	task.taskUID = calTask.uid;
	[self copyCalTask:calTask toNativeTask:task];
	[context insertObject:task];
}

- (void)awakeFromNib {
	calendarStore = [CalCalendarStore defaultCalendarStore];
	context = [appDelegate managedObjectContext];	
	
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSString* defaultCalendarUID = [defaults stringForKey:DefaultCalendarKey];
	if (!defaultCalendarUID || ![calendarStore calendarWithUID:defaultCalendarUID]) {
		[defaults setObject:[[[calendarStore calendars] objectAtIndex:0] uid] forKey:DefaultCalendarKey];
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

- (void)objectsDidChange:(NSNotification*)notification {
	NSDictionary* userInfo = [notification userInfo];
	NSEntityDescription* taskEntity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:[appDelegate managedObjectContext]];
	NSSet* inserted = [userInfo objectForKey:NSInsertedObjectsKey];
	for (id object in inserted) {
		if ([[object entity] isEqualTo:taskEntity]) {
			Task* task = object;
			if (!task.taskUID) {
				CalTask* calTask = [CalTask task];
				calTask.calendar = [calendarStore calendarWithUID:[[NSUserDefaults standardUserDefaults] stringForKey:DefaultCalendarKey]];
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
				CalTask* calTask = [calendarStore taskWithUID:task.taskUID];
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
				CalTask* calTask = [calendarStore taskWithUID:task.taskUID];
				if (calTask) {
					NSError* error;
					if (![calendarStore removeTask:calTask error:&error]) {
						[NSApp presentError:error];
					}
				} else {
					NSLog(@"Deleted task with invalid task UID %@", task.taskUID);
				}
			} else {
				NSLog(@"Deleted task without a UID");
			}
			[self deleteEventForTask:task];
		}
	}
}

- (void)tasksChanged:(NSNotification*)notification {
	NSDictionary* userInfo = [notification userInfo];
	for (NSString* uid in [userInfo objectForKey:CalInsertedRecordsKey]) {
		CalTask* calTask = [calendarStore taskWithUID:uid];
		if ([[self isInDefaultCalendarPredicate] evaluateWithObject:calTask]) {
			[self insertedCalTask:calTask];
		}
	}
	for (NSString* uid in [userInfo objectForKey:CalUpdatedRecordsKey]) {
		CalTask* calTask = [calendarStore taskWithUID:uid];
		if (calTask) {
			Task* task = [Task taskWithTaskUID:uid inManagedObjectContext:context];
			if (task) {
				[self copyCalTask:calTask toNativeTask:task];
			} else {
				NSLog(@"Updated CalTask with invalid UID %@", uid);
			}
		} else {
			NSLog(@"Updated non-existing CalTask %@", uid);
		}
	}
	for (NSString* uid in [userInfo objectForKey:CalDeletedRecordsKey]) {
		Task* task = [Task taskWithTaskUID:uid inManagedObjectContext:context];
		if (task) {
			[self deletedCalTaskCorrespondingToNativeTask:task];
		} else {
			NSLog(@"Deleted CalTask with invalid UID %@", uid);
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
