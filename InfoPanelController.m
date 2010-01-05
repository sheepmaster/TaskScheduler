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
	return [[Task tasksMatchingPredicate:[NSPredicate predicateWithFormat:@"title beginswith[cd] %@", substring] inManagedObjectContext:context] valueForKey:@"title"];
}

- (id)tokenField:(NSTokenField *)tokenField representedObjectForEditingString:(NSString *)editingString {
	NSManagedObjectContext* context = [appDelegate managedObjectContext];
	NSArray* tasks = [Task tasksMatchingPredicate:[NSPredicate predicateWithFormat:@"title == %@", editingString] inManagedObjectContext:context];
	return [tasks objectAtIndex:0];
}

- (NSString*)tokenField:(NSTokenField *)tokenField displayStringForRepresentedObject:(id)representedObject {
	return ((Task*)representedObject).title;
}

- (BOOL)tokenField:(NSTokenField *)tokenField hasMenuForRepresentedObject:(id)representedObject {
	return NO;
}

@end
