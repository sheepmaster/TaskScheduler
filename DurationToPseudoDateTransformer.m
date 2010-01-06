//
//  DurationToPseudoDateTransformer.m
//  TaskScheduler
//
//  Created by Bernhard Bauer on 06.01.10.
//  Copyright 2010 Black Sheep Software. All rights reserved.
//

#import "DurationToPseudoDateTransformer.h"


@implementation DurationToPseudoDateTransformer

+ (Class)transformedValueClass {
	return [NSDate class];
}

+ (BOOL)allowsReverseTransformation { 
	return YES; 
}

- (id)transformedValue:(id)value {
	if (!value) {
		return nil;
	}
	double duration = [value doubleValue];
	
	NSLog(@"transformed %@ to %@", value, [NSDate dateWithTimeIntervalSinceReferenceDate:duration]);
    return [NSDate dateWithTimeIntervalSinceReferenceDate:duration];
}

- (id)reverseTransformedValue:(id)value {
	if (![value isKindOfClass:[NSDate class]]) {
		return nil;
	}
	NSDate* date = value;
	NSLog(@"reverse transformed %@ to %@", value, [NSNumber numberWithInt:(int)[date timeIntervalSinceReferenceDate]]);
	return [NSNumber numberWithInt:(int)[date timeIntervalSinceReferenceDate]];
}

@end
