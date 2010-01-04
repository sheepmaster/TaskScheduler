//
//  TaskWindowController.m
//  TaskScheduler
//
//  Created by Bernhard Bauer on 06.12.09.
//  Copyright 2009 Black Sheep Software. All rights reserved.
//

#import "TaskWindowController.h"

#import "InfoPanelController.h"


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

- (IBAction)completed:(id)sender {
	
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
	if (aTableColumn == completedColumn) {
		NSManagedObject* task = [[taskController arrangedObjects] objectAtIndex:rowIndex];
		[task setValue:([anObject boolValue] ? [NSDate date] : nil) forKeyPath:@"completed"];
//		NSLog(@"task: %@", task);
//		if ([anObject boolValue]) {
//			tmp.completed = [NSDate date];
//		} else {
//			tmp.completed = nil;
//		}
	}
}

@end
