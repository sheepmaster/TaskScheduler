//
//  TaskWindowController.m
//  TaskScheduler
//
//  Created by Bernhard Bauer on 06.12.09.
//  Copyright 2009 Black Sheep Software. All rights reserved.
//

#import "TaskWindowController.h"

#import "NSArrayController+TaskScheduler.h"
#import "InfoPanelController.h"
#import "Task.h"
#import "TaskCell.h"

@implementation TaskWindowController

- (void)awakeFromNib {
	[taskList setTarget:infoPanelController];
	[taskList setDoubleAction:@selector(showWindow:)];
//	[taskList setAction:@selector(showInfoPanel:)];
}

/**
 Returns the NSUndoManager for the application.  In this case, the manager
 returned is that of the managed object context for the application.
 */

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[appDelegate managedObjectContext] undoManager];
}

//- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
//	[infoPanelController hideInfoPanel:nil];
//}

- (IBAction)addTask:(id)sender {
	NSUInteger row = [taskController addNewObject];
	if (row != -1) {
		[taskList editColumn:[taskList columnWithIdentifier:@"task"] row:row withEvent:nil select:YES];
	}
}

/*
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	if ([[tableColumn identifier] isEqualToString:@"task"]) {
		return [[taskController arrangedObjects] objectAtIndex:row];
	}
	return nil;
}
*/

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	if ([cell isKindOfClass:[TaskCell class]]) {
		TaskCell* taskCell = cell;
		Task* task = [[taskController arrangedObjects] objectAtIndex:row];
		taskCell.task = task;
	}
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
	Task* task = [[taskController arrangedObjects] objectAtIndex:rowIndex];
	NSString* identifier = [aTableColumn identifier];
	if ([identifier isEqualToString:@"completed"]) {
		task.completedDate = [anObject boolValue] ? [NSDate date] : nil;
	} else if ([identifier isEqualToString:@"task"]) {
		task.title = anObject;
	}
}

@end
