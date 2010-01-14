//
//  PreferencesController.m
//  TaskScheduler
//
//  Created by Bernhard Bauer on 14.01.10.
//  Copyright 2010 Black Sheep Software. All rights reserved.
//

#import "PreferencesController.h"

static NSString* CreateCalTaskForNewTaskKey = @"CreateCalTaskForNewTask";
static NSString* CreateTaskForNewCalTaskKey = @"CreateTaskForNewCalTask";
static NSString* DeleteTaskForDeletedCalTaskKey = @"DeleteTaskForDeletedCalTask";
static NSString* CreateEventForScheduledTaskKey = @"CreateEventForScheduledTask";
static NSString* UnscheduleTaskForDeletedEventKey = @"UnscheduleTaskForDeletedEvent";


@implementation PreferencesController

+ (void)initialize {
	NSMutableDictionary* defaultValues = [NSMutableDictionary dictionary];
	[defaultValues setObject:[NSNumber numberWithBool:YES] forKey:CreateCalTaskForNewTaskKey];
	[defaultValues setObject:[NSNumber numberWithBool:YES] forKey:CreateTaskForNewCalTaskKey];
	[defaultValues setObject:[NSNumber numberWithBool:YES] forKey:DeleteTaskForDeletedCalTaskKey];
	[defaultValues setObject:[NSNumber numberWithBool:YES] forKey:CreateEventForScheduledTaskKey];
	[defaultValues setObject:[NSNumber numberWithBool:YES] forKey:UnscheduleTaskForDeletedEventKey];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
}


@end
