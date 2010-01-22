//
//  NSMutableAttributedString+TaskScheduler.m
//  TaskScheduler
//
//  Created by Bernhard Bauer on 22.01.10.
//  Copyright 2010 Black Sheep Software. All rights reserved.
//

#import "NSMutableAttributedString+TaskScheduler.h"


@implementation NSMutableAttributedString(TaskScheduler)

- (void)appendString:(NSString*)string {
	[self appendString:string withAttributes:nil];
}

- (void)appendString:(NSString*)string withAttributes:(NSDictionary*)attributes {
	NSAttributedString* attributedString = [[NSAttributedString alloc] initWithString:string attributes:attributes];
	[self appendAttributedString:attributedString];
	[attributedString release];
}

@end
