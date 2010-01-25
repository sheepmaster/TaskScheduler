//
//  SetToArrayTransformer.m
//  TaskScheduler
//
//  Created by Bernhard Bauer on 06.01.10.
//  Copyright 2010 Black Sheep Software. All rights reserved.
//

#import "SetToArrayTransformer.h"

@class Task;

@implementation SetToArrayTransformer

+ (Class)transformedValueClass {
	return [NSArray class];
}

+ (BOOL)allowsReverseTransformation { 
	return YES; 
}

- (id)transformedValue:(id)value {
	if (![value isKindOfClass:[NSSet class]]) {
		return nil;
	}
	NSSet* set = value;
    return [set allObjects];
}

- (id)reverseTransformedValue:(id)value {
	if (![value isKindOfClass:[NSArray class]]) {
		return nil;
	}
	NSArray* array = value;
	NSMutableSet* set = [NSMutableSet set];
	for (id element in array) {
		if ([element isKindOfClass:[Task class]]) {
			[set addObject:element];
		}
	}
	return set;
}

@end
