//
//  InfoPanelController.h
//  TaskScheduler
//
//  Created by Bernhard Bauer on 06.12.09.
//  Copyright 2009 Black Sheep Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class TaskScheduler_AppDelegate;
@class ICalController;

@interface InfoPanelController : NSWindowController {
	IBOutlet NSTreeController* tasksController;
	IBOutlet ICalController* iCalController;
	NSMutableSet* excludedTasks;
	
	IBOutlet TaskScheduler_AppDelegate* appDelegate;
	
	IBOutlet NSTextField* startDateField;
	IBOutlet NSTextField* dueDateField;
	IBOutlet NSTextField* scheduledDateField;
	IBOutlet NSTextField* completedDateField;	
	IBOutlet NSDatePickerCell* durationFieldCell;
	
	NSAppleScript* revealInICalAppleScript;
}

- (NSAppleScript*)revealInICalAppleScript;

- (IBAction)toggleWindow:(id)sender;

- (IBAction)createTaskInICal:(id)sender;
- (IBAction)revealTaskInICal:(id)sender;
- (IBAction)scheduleTaskInICal:(id)sender;
- (IBAction)revealScheduledTaskInICal:(id)sender;

@end
