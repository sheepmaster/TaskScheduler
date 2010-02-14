//
//  DurationFormatter.m
//  TaskScheduler
//
//  Created by Bernhard Bauer on 06.01.10.
//  Copyright 2010 Black Sheep Software. All rights reserved.
//

#import "DurationFormatter.h"


@implementation DurationFormatter

- (NSString *)stringForObjectValue:(id)anObject {
	if (![anObject isKindOfClass:[NSNumber class]]) {
		return nil;
	}
	int duration = [anObject intValue];
	int hours = (duration / 3600);
	int minutes = (duration % 3600) / 60;
	return [NSString stringWithFormat:@"%d:%02d", hours, minutes];
}

- (BOOL)getObjectValue:(id *)anObject forString:(NSString *)string errorDescription:(NSString **)error {
	NSArray* components = [string componentsSeparatedByString:@":"];
	if ([components count] == 0) {
		return NO;
	} else {
		int duration = [[components objectAtIndex:0] intValue];
		if ([components count] == 2) {
			duration = duration * 60 + [[components objectAtIndex:1] intValue];
		} else if ([components count] > 2) {
			return NO;
		}
		*anObject = [NSNumber numberWithInt:(duration*60)];
		NSLog(@"value: %@", *anObject);
		return YES;
	}
}



@end
