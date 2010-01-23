//
//  TaskWindowController.h
//  TaskScheduler
//
//  Created by Bernhard Bauer on 06.12.09.
//  Copyright 2009 Black Sheep Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TaskScheduler_AppDelegate.h"

@class InfoPanelController;

@interface TaskWindowController : NSWindowController {
	IBOutlet TaskScheduler_AppDelegate* appDelegate;
	IBOutlet NSTableView* taskList;
	IBOutlet InfoPanelController* infoPanelController;

	IBOutlet NSArrayController* taskController;
}

- (IBAction)addTask:(id)sender;

@end
