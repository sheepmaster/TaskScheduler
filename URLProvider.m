//
//  URLProvider.m
//  TaskScheduler
//
//  Created by Bernhard Bauer on 21.02.10.
//  Copyright 2010 Black Sheep Software. All rights reserved.
//

#import "URLProvider.h"


@implementation URLProvider

- (NSArray*)completionsForString:(NSString*)string {
	NSLog(@"completionsForString: not implemented");
	return [NSArray array];
}

- (URL*)urlForString:(NSString*)string {
	NSLog(@"urlForString: not implemented");
	return nil;
}

@end
