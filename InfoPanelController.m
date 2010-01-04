//
//  InfoPanelController.m
//  TaskScheduler
//
//  Created by Bernhard Bauer on 06.12.09.
//  Copyright 2009 Black Sheep Software. All rights reserved.
//

#import "InfoPanelController.h"


@implementation InfoPanelController

- (void)awakeFromNib {
	NSDateFormatter* formatter = [[NSDateFormatter alloc] initWithDateFormat:@"%c" allowNaturalLanguage:YES];
	[formatter setDateStyle:NSDateFormatterMediumStyle];
	[formatter setTimeStyle:NSDateFormatterShortStyle];
	[formatter setDoesRelativeDateFormatting:YES];
	[formatter setLenient:YES];
	
	[startDateField setFormatter:formatter];
	[dueDateField setFormatter:formatter];
	[scheduledDateField setFormatter:formatter];
//	[completedDateField setFormatter:formatter];
}

					 

- (IBAction)toggleWindow:(id)sender {
	NSWindow* window = [self window];
	if ([window isVisible]) {
		[window orderOut:sender];
	} else {
		[self showWindow:sender]; 
	}
}


@end
