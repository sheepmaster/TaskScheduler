//
//  ICalController.h
//  TaskScheduler
//
//  Created by Bernhard Bauer on 01.01.10.
//  Copyright 2010 Black Sheep Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CalendarStore/CalendarStore.h>

@class TaskScheduler_AppDelegate;
@class Task;

@interface ICalController : NSObject {
	IBOutlet TaskScheduler_AppDelegate* appDelegate;
	
	NSManagedObjectContext* context;
	CalCalendarStore* calendarStore;
}

@property(readonly) NSArray *calendars;

- (void)synchronize;

- (void)deletedCalTaskCorrespondingToNativeTask:(Task*)task;
- (void)insertedCalTask:(CalTask*)calTask;

- (BOOL) copyNativeTask:(Task*)task toCalTask:(CalTask*)calTask;
- (BOOL) copyCalTask:(CalTask*)calTask toNativeTask:(Task*)task;
- (void) copyCalEvent:(CalEvent*)event toTask:(Task*)task;
- (void) unscheduleTask:(Task*)task;
- (void) deleteEventForTask:(Task*)uid;

@end
