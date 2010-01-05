//
//  Task.m
//  TaskScheduler
//
//  Created by Bernhard Bauer on 03.01.10.
//  Copyright 2010 Black Sheep Software. All rights reserved.
//

#import "Task.h"


@implementation Task

+ (Task*) taskWithTaskUID:(NSString*)uid inManagedObjectContext:(NSManagedObjectContext*)context {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Task"
											  inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	
	NSPredicate* predicateTemplate = [NSPredicate predicateWithFormat:@"taskUID == $UID"];
	NSPredicate* predicate = [predicateTemplate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObject:uid forKey:@"UID"]];
	[fetchRequest setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	id task = nil;
	if (fetchedObjects == nil) {
		[NSApp presentError:error];
	} else if ([fetchedObjects count] != 1) {
		NSLog(@"Found %d tasks with UID %@", [fetchedObjects count], uid);
	} else {
		task = [fetchedObjects objectAtIndex:0];
	}
	
	[fetchRequest release];

	return task;
}

+ (Task*) taskWithEventUID:(NSString*)uid inManagedObjectContext:(NSManagedObjectContext*)context {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Task"
											  inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	
	NSPredicate* predicateTemplate = [NSPredicate predicateWithFormat:@"eventUID == $UID"];
	NSPredicate* predicate = [predicateTemplate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObject:uid forKey:@"UID"]];
	[fetchRequest setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	id task = nil;
	if (fetchedObjects == nil) {
		[NSApp presentError:error];
	} else if ([fetchedObjects count] != 1) {
		NSLog(@"Found %d tasks with event UID %@", [fetchedObjects count], uid);
	} else {
		task = [fetchedObjects objectAtIndex:0];
	}
	
	[fetchRequest release];
	
	return task;
}

+ (NSArray*)allTasksInManagedObjectContext:(NSManagedObjectContext*)context {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Task"
											  inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
		
	NSError *error = nil;
	NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	if (fetchedObjects == nil) {
		[NSApp presentError:error];
	}
	[fetchRequest release];
	return fetchedObjects;
}

- (id)initWithManagedObjectContext:(NSManagedObjectContext*)context {
	if (self = [super initWithEntity:[NSEntityDescription entityForName:@"Task" inManagedObjectContext:context] insertIntoManagedObjectContext:context]) {
		
	}
	return self;
}

/*
- (Status)status {
	if (completed < now) {
		return StatusCompleted;
	} else if ((start > now) || (max(dependsOn.completed) > now)) {
		return StatusPending;
	} else if (!scheduled) {
		return StatusPossible;
	} else if (scheduled > now) {
		return StatusInactive;
	} else {
		return StatusActive;
	}
}
 */

@end
