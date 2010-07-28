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
	if (![taskController commitEditing]) {
		return;
	}
	
	id newObject = [storedTasks newObject];
	
	[taskController addObject:newObject];
	[newObject release];
	
	[taskController rearrangeObjects];
	
	NSTreeNode* node = [NSTreeNode treeNodeWithRepresentedObject:newObject];
	NSInteger row = [taskList rowForItem:node];
	
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

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {
	if ([cell isKindOfClass:[TaskCell class]]) {
		TaskCell* taskCell = cell;
		Task* task = [item representedObject];
		taskCell.task = task;
	}
}

- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn item:(id)item {
	Task* task = [item representedObject];
	NSString* identifier = [aTableColumn identifier];
	if ([identifier isEqualToString:@"completed"]) {
		task.completedDate = [anObject boolValue] ? [NSDate date] : nil;
	} else if ([identifier isEqualToString:@"task"]) {
		task.title = anObject;
	}
}

@end
