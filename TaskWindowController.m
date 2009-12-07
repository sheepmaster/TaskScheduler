//
//  TaskWindowController.m
//  TaskScheduler
//
//  Created by Bernhard Bauer on 06.12.09.
//  Copyright 2009 Black Sheep Software. All rights reserved.
//

#import "TaskWindowController.h"


@implementation TaskWindowController

- (void)awakeFromNib {
//	[taskList setTarget:infoPanelController];
//	[taskList setDoubleAction:@selector(showInfoPanel:)];
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

@end
