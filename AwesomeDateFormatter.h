//
//  AwesomeDateFormatter.h
//  TaskScheduler
//
//  Created by Bernhard Bauer on 20.12.09.
//  Copyright 2009 Black Sheep Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AwesomeDateFormatter : NSFormatter {
	NSDateFormatter* inputFormatter;
	NSDateFormatter* outputFormatter;
}

@end
