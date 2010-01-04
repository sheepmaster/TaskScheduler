//
//  InfoPanelController.h
//  TaskScheduler
//
//  Created by Bernhard Bauer on 06.12.09.
//  Copyright 2009 Black Sheep Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface InfoPanelController : NSWindowController {
	IBOutlet NSTextField* startDateField;
	IBOutlet NSTextField* dueDateField;
	IBOutlet NSTextField* scheduledDateField;
	IBOutlet NSTextField* completedDateField;	
	IBOutlet NSDatePickerCell* durationFieldCell;
}

- (IBAction)toggleWindow:(id)sender;

@end