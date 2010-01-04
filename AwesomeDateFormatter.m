//
//  AwesomeDateFormatter.m
//  TaskScheduler
//
//  Created by Bernhard Bauer on 20.12.09.
//  Copyright 2009 Black Sheep Software. All rights reserved.
//

#import "AwesomeDateFormatter.h"


@implementation AwesomeDateFormatter

- (id)init {
	if (self = [super init]) {
		inputFormatter = [[NSDateFormatter alloc] initWithDateFormat:@"x" allowNaturalLanguage:YES];
		[inputFormatter setLenient:YES];
		[inputFormatter setDoesRelativeDateFormatting:YES];
	}
	return self;
}

- (void)dealloc {
	[inputFormatter release];
	inputFormatter = nil;
	[super dealloc];
}

- (NSString*)stringForObjectValue:(id)obj {
	return [NSDateFormatter localizedStringFromDate:obj dateStyle: NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle];
}

- (BOOL)getObjectValue:(id *)anObject forString:(NSString *)string errorDescription:(NSString **)error {
	return [inputFormatter getObjectValue:anObject forString:string errorDescription:error];
}

@end
