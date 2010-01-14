//
//  PreferencesController.m
//  TaskScheduler
//
//  Created by Bernhard Bauer on 14.01.10.
//  Copyright 2010 Black Sheep Software. All rights reserved.
//

#import "PreferencesController.h"

NSString* CreateCalTaskForNewTaskKey = @"CreateCalTaskForNewTask";
NSString* CreateTaskForNewCalTaskKey = @"CreateTaskForNewCalTask";
NSString* DeleteTaskForDeletedCalTaskKey = @"DeleteTaskForDeletedCalTask";
NSString* CreateEventForScheduledTaskKey = @"CreateEventForScheduledTask";
NSString* UnscheduleTaskForDeletedEventKey = @"UnscheduleTaskForDeletedEvent";
NSString* UseCustomScheduleCalendarKey = @"UseCustomScheduleCalendar";


@implementation PreferencesController

+ (void)initialize {
	NSMutableDictionary* defaultValues = [NSMutableDictionary dictionary];
	[defaultValues setObject:[NSNumber numberWithBool:YES] forKey:CreateCalTaskForNewTaskKey];
	[defaultValues setObject:[NSNumber numberWithBool:YES] forKey:CreateTaskForNewCalTaskKey];
	[defaultValues setObject:[NSNumber numberWithBool:YES] forKey:DeleteTaskForDeletedCalTaskKey];
	[defaultValues setObject:[NSNumber numberWithBool:YES] forKey:CreateEventForScheduledTaskKey];
	[defaultValues setObject:[NSNumber numberWithBool:YES] forKey:UnscheduleTaskForDeletedEventKey];
	[defaultValues setObject:[NSNumber numberWithBool:NO] forKey:UseCustomScheduleCalendarKey];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
}


@end
