//
//  PlainURLProvider.m
//  TaskScheduler
//
//  Created by Bernhard Bauer on 21.02.10.
//  Copyright 2010 Black Sheep Software. All rights reserved.
//

#import "PlainURLProvider.h"

#import "URL.h"

@implementation PlainURLProvider

- (NSArray*)completionsForString:(NSString*)string {
	NSURL* url = [NSURL URLWithString:string];
	return (url) ? [NSArray arrayWithObject:[url standardizedURL]] : [NSArray array];
	// TODO autocomplete file: URLs?
}

- (URL*)urlForString:(NSString*)string {
	URL* url = [[URL alloc] init];
	url.url = string;
	url.title = string;
}

@end
