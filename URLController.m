//
//  URLController.m
//  TaskScheduler
//
//  Created by Bernhard Bauer on 21.02.10.
//  Copyright 2010 Black Sheep Software. All rights reserved.
//

#import "URLController.h"


@implementation URLController

- (NSArray*)tokenField:(NSTokenField *)tokenField completionsForSubstring:(NSString *)substring indexOfToken:(NSInteger)tokenIndex indexOfSelectedItem:(NSInteger *)selectedIndex {
}

- (id)tokenField:(NSTokenField *)tokenField representedObjectForEditingString:(NSString *)editingString {
}

- (NSArray *)tokenField:(NSTokenField *)tokenField shouldAddObjects:(NSArray *)tokens atIndex:(NSUInteger)index {
	NSMutableArray* filteredArray = [NSMutableArray array];
	for (id token in tokens) {
		if ([token isKindOfClass:[URL class]]) {
			[filteredArray addObject:token];
		}
	}
	
	[tokenField performSelector:@selector(validateEditing) withObject:nil afterDelay:0];
	return filteredArray;
}

- (NSString*)tokenField:(NSTokenField *)tokenField displayStringForRepresentedObject:(id)representedObject {
	if ([representedObject isKindOfClass:[URL class]]) {
		URL* url = representedObject;
		return url.title;
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
