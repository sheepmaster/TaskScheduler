//
//  InfoPanelController.m
//  TaskScheduler
//
//  Created by Bernhard Bauer on 06.12.09.
//  Copyright 2009 Black Sheep Software. All rights reserved.
//

#import "InfoPanelController.h"
#import "Task.h"

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
	[excludedTasks release];
	excludedTasks = [[NSMutableSet alloc] init];

	for (Task* task in selectedObjects) {
		[excludedTasks unionSet:task.dependsOn];
		[excludedTasks unionSet:task.transitiveEnables];
	}
	
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
		if (![token isKindOfClass:[NSString class]]) {
			[filteredArray addObject:token];
		}
	}
	return filteredArray;
}

- (NSString*)tokenField:(NSTokenField *)tokenField displayStringForRepresentedObject:(id)representedObject {
	return ((Task*)representedObject).title;
}

- (BOOL)tokenField:(NSTokenField *)tokenField hasMenuForRepresentedObject:(id)representedObject {
	return NO;
}

@end
