//
//  InfoPanelController.h
//  TaskScheduler
//
//  Created by Bernhard Bauer on 06.12.09.
//  Copyright 2009 Black Sheep Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class TaskScheduler_AppDelegate;

@interface InfoPanelController : NSWindowController {
	IBOutlet NSArrayController* tasksController;
	NSSet* excludedTasks;
	
	IBOutlet TaskScheduler_AppDelegate* appDelegate;
	
	IBOutlet NSTextField* startDateField;
	IBOutlet NSTextField* dueDateField;
	IBOutlet NSTextField* scheduledDateField;
	IBOutlet NSTextField* completedDateField;	
	IBOutlet NSDatePickerCell* durationFieldCell;
}

- (IBAction)toggleWindow:(id)sender;

@end
