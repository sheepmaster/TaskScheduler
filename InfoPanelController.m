//
//  InfoPanelController.m
//  TaskScheduler
//
//  Created by Bernhard Bauer on 06.12.09.
//  Copyright 2009 Black Sheep Software. All rights reserved.
//

#import "InfoPanelController.h"

#import "ICalController.h"
#import "Task.h"
#import "NSAppleScript+TaskScheduler.h"

@implementation InfoPanelController

- (void)awakeFromNib {
//	[tasksController addObserver:self forKeyPath:@"selectedObjects" options:0 context:nil];
	[tasksController addObserver:self forKeyPath:@"selection.dependsOn" options:0 context:nil];
	[tasksController addObserver:self forKeyPath:@"arrangedObjects" options:0 context:nil];
	
//	NSDateFormatter* formatter = [[NSDateFormatter alloc] initWithDateFormat:@"%x" allowNaturalLanguage:YES];
//	[formatter setDateStyle:NSDateFormatterMediumStyle];
//	[formatter setTimeStyle:NSDateFormatterShortStyle];
//	[formatter setDoesRelativeDateFormatting:YES];
//	[formatter setLenient:YES];
//	
//	[startDateField setFormatter:formatter];
//	[dueDateField setFormatter:formatter];
//	[scheduledDateField setFormatter:formatter];
//	[completedDateField setFormatter:formatter];
//	[formatter release];
	excludedTasks = [[NSSet alloc] init];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//	NSLog(@"change: %@", change);
	NSArray* selectedObjects = [tasksController selectedObjects];
//	if ([selectedObjects count] != 1) {
//		return;
//	}
//	id selectedTask = [selectedObjects objectAtIndex:0];
//	NSLog(@"selected task: %@", selectedTask);
	NSMutableSet* newExcludedTasks = [[NSMutableSet alloc] init];

	for (Task* task in selectedObjects) {
		[newExcludedTasks unionSet:task.dependsOn];
		[newExcludedTasks unionSet:task.transitiveEnables];
	}
	
	[excludedTasks release];
	excludedTasks = newExcludedTasks;
//	NSLog(@"excludedTasks: %@", [excludedTasks valueForKey:@"title"]);
}

- (IBAction)toggleWindow:(id)sender {
	NSWindow* window = [self window];
	if ([window isVisible]) {
		[window orderOut:sender];
	} else {
		[self showWindow:sender]; 
	}
}

- (NSAppleScript*)revealInICalAppleScript {
	if (!revealInICalAppleScript) {
		// load the script from a resource by fetching its URL from within our bundle
		NSString* path = [[NSBundle mainBundle] pathForResource:@"RevealInICal" ofType:@"scpt"];
		if (path) {
			NSURL* url = [NSURL fileURLWithPath:path];
			if (url) {
				NSDictionary* errors = [NSDictionary dictionary];
				revealInICalAppleScript = [[NSAppleScript alloc] initWithContentsOfURL:url error:&errors];
				if (!revealInICalAppleScript) {
					NSLog(@"Couldn't load applescript: %@", errors);
				}
			} else {
				NSLog(@"Couldn't create URL from path %@", path);
			}
		} else {
			NSLog(@"Couldn't find RevealInICal.scpt in Resources");
		}
	}
	return revealInICalAppleScript;
}

- (IBAction)createTaskInICal:(id)sender {
	for (Task* task in [tasksController selectedObjects]) {
		if (!task.taskUID) {
			[iCalController createCalTaskForTask:task];
		} else {
			NSLog(@"Task %@ already has a CalTask (%@)", task.title, task.taskUID);
		}
	} 
}

- (IBAction)revealTaskInICal:(id)sender {
	NSArray* selectedObjects = [tasksController selectedObjects];
	if ([selectedObjects count] != 1) {
		NSLog(@"Can't reveal multiple tasks");
		return;
	}
	Task* task = [selectedObjects objectAtIndex:0];
	if (!task.eventUID) {
		NSLog(@"Task %@ doesn't exist in iCal", task.title);
		return;
	}
	CalTask* calTask = [[CalCalendarStore defaultCalendarStore] taskWithUID:task.taskUID];
	if (!calTask) {
		NSLog(@"Invalid taskUID %@ for task %@", task.taskUID, task.title);
	}
	
	NSAppleScript* appleScript = [self revealInICalAppleScript];
	
	NSDictionary* error = nil;
	if (![appleScript callSubroutineNamed:@"reveal_task" withParameters:[NSArray arrayWithObjects:calTask.uid, calTask.calendar.uid, nil] error:&error]) {
		NSLog(@"Couldn't execute applescript: %@", error);
	}			
}

- (IBAction)scheduleTaskInICal:(id)sender {
	for (Task* task in [tasksController selectedObjects]) {
		if (!task.eventUID) {
			[iCalController createEventForTask:task];
		} else {
			NSLog(@"Task %@ already has an event (%@)", task.title, task.eventUID);
		}
	} 
}

- (IBAction)revealScheduledTaskInICal:(id)sender {
	NSArray* selectedObjects = [tasksController selectedObjects];
	if ([selectedObjects count] != 1) {
		NSLog(@"Can't reveal multiple scheduled tasks");
		return;
	}
	Task* task = [selectedObjects objectAtIndex:0];
	if (!task.eventUID) {
		NSLog(@"Task %@ has no event in iCal", task.title);
		return;
	}
	CalEvent* event = [[CalCalendarStore defaultCalendarStore] eventWithUID:task.eventUID occurrence:nil];
	if (!event) {
		NSLog(@"Invalid eventUID %@ for task %@", task.eventUID, task.title);
	}
	
	NSAppleScript* appleScript = [self revealInICalAppleScript];

	NSDictionary* error = nil;
	if (![appleScript callSubroutineNamed:@"reveal_event" withParameters:[NSArray arrayWithObjects:event.uid, event.calendar.uid, nil] error:&error]) {
		NSLog(@"Couldn't execute applescript: %@", error);
	}			
}


- (NSArray*)tokenField:(NSTokenField *)tokenField completionsForSubstring:(NSString *)substring indexOfToken:(NSInteger)tokenIndex indexOfSelectedItem:(NSInteger *)selectedIndex {
	NSManagedObjectContext* context = [appDelegate managedObjectContext];
	return [[Task tasksMatchingPredicate:[NSPredicate predicateWithFormat:@"(title beginswith[cd] %@) && !(SELF IN %@)", substring, excludedTasks] inManagedObjectContext:context] valueForKey:@"title"];
}

- (id)tokenField:(NSTokenField *)tokenField representedObjectForEditingString:(NSString *)editingString {
	NSManagedObjectContext* context = [appDelegate managedObjectContext];
	NSArray* tasks = [Task tasksMatchingPredicate:[NSPredicate predicateWithFormat:@"(title == %@) && !(SELF IN %@)", editingString, excludedTasks] inManagedObjectContext:context];
	if ([tasks count] > 0) {
		return [tasks objectAtIndex:0];
	} else {
		return nil;
	}
}

- (NSArray *)tokenField:(NSTokenField *)tokenField shouldAddObjects:(NSArray *)tokens atIndex:(NSUInteger)index {
	NSMutableArray* filteredArray = [NSMutableArray array];
	for (id token in tokens) {
		if ([token isKindOfClass:[Task class]]) {
			[filteredArray addObject:token];
		}
	}
	return filteredArray;
}

- (NSString*)tokenField:(NSTokenField *)tokenField displayStringForRepresentedObject:(id)representedObject {
	if ([representedObject isKindOfClass:[Task class]]) {
		Task* task = representedObject;
		return task.title;
	} else if ([representedObject isKindOfClass:[NSString class]]) {
		return representedObject;
	} else {
		return [representedObject description];
	}
}

- (BOOL)tokenField:(NSTokenField *)tokenField hasMenuForRepresentedObject:(id)representedObject {
	return NO;
}

@end
