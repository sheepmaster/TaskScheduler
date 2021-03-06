//
//  TaskScheduler_AppDelegate.h
//  TaskScheduler
//
//  Created by Bernhard Bauer on 01.12.09.
//  Copyright Black Sheep Software 2009 . All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TaskScheduler_AppDelegate : NSObject 
{
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
	
	NSTimer* saveTimer;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (NSManagedObjectModel *)managedObjectModel;
- (NSManagedObjectContext *)managedObjectContext;

- (IBAction)saveAction:sender;

@end
