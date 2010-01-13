//
//  StatusController.h
//  TaskScheduler
//
//  Created by Bernhard Bauer on 13.01.10.
//  Copyright 2010 Black Sheep Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class StatusChange;
@class TaskScheduler_AppDelegate;

@interface StatusController : NSObject {
	IBOutlet NSArrayController* statusChanges;
	IBOutlet TaskScheduler_AppDelegate* appDelegate;
	
	NSManagedObjectContext* context;
	StatusChange* nextChange;
	NSTimer* nextChangeTimer;
}

@end
