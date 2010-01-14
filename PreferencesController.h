//
//  PreferencesController.h
//  TaskScheduler
//
//  Created by Bernhard Bauer on 14.01.10.
//  Copyright 2010 Black Sheep Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString* CreateCalTaskForNewTaskKey;
extern NSString* CreateTaskForNewCalTaskKey;
extern NSString* DeleteTaskForDeletedCalTaskKey;
extern NSString* CreateEventForScheduledTaskKey;
extern NSString* UnscheduleTaskForDeletedEventKey;
extern NSString* UseCustomScheduleCalendarKey;


@interface PreferencesController : NSWindowController {

}

@end
