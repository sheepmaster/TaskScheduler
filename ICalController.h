//
//  ICalController.h
//  TaskScheduler
//
//  Created by Bernhard Bauer on 01.01.10.
//  Copyright 2010 Black Sheep Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TaskScheduler_AppDelegate;

@interface ICalController : NSObject {
	IBOutlet TaskScheduler_AppDelegate* appDelegate;
}

@property(readonly) NSArray *calendars;

- (void) calendarsChanged:(NSNotification *)notification;

@end
