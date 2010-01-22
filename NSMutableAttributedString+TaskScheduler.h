//
//  NSMutableAttributedString+TaskScheduler.h
//  TaskScheduler
//
//  Created by Bernhard Bauer on 22.01.10.
//  Copyright 2010 Black Sheep Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSMutableAttributedString(TaskScheduler)
	
- (void)appendString:(NSString*)string;

- (void)appendString:(NSString*)string withAttributes:(NSDictionary*)attributes;

@end
