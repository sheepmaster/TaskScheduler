//
//  Task.m
//  TaskScheduler
//
//  Created by Bernhard Bauer on 03.01.10.
//  Copyright 2010 Black Sheep Software. All rights reserved.
//

#import "Task.h"


@implementation Task

@dynamic completed;
@dynamic due;
@dynamic duration;
@dynamic eventUID;
@dynamic flagged;
@dynamic notes;
@dynamic priority;
@dynamic scheduled;
@dynamic start;
@dynamic taskUID;
@dynamic title;
@dynamic dependsOn;
@dynamic enables;

- (void)visitWithSet:(NSMutableSet*)set {
	if ([set member:self]) {
		return;
	}
	[set addObject:self];
	for (Task* neighbour in self.enables) {
		[neighbour visitWithSet:set];
	}
}

- (NSSet*)transitiveEnables {
	NSMutableSet* set = [NSMutableSet set];
	[self visitWithSet:set];
	return set;
}

+ (Task*) taskWithTaskUID:(NSString*)uid inManagedObjectContext:(NSManagedObjectContext*)context {
	NSPredicate* predicateTemplate = [NSPredicate predicateWithFormat:@"taskUID == $UID"];
	NSPredicate* predicate = [predicateTemplate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObject:uid forKey:@"UID"]];
	return [self taskMatchingPredicate:predicate inManagedObjectContext:context];
}

+ (Task*) taskMatchingPredicate:(NSPredicate*)predicate inManagedObjectContext:(NSManagedObjectContext*)context {
	NSArray* tasks = [self tasksMatchingPredicate:predicate inManagedObjectContext:context];
	if ([tasks count] != 1) {
		NSLog(@"Found %d tasks matching predicate", [tasks count], predicate);
		return nil;
	} else {
		return [tasks objectAtIndex:0];
	}
}

+ (NSArray*)allTasksInManagedObjectContext:(NSManagedObjectContext*)context {
	return [self tasksMatchingPredicate:[NSPredicate predicateWithValue:YES] inManagedObjectContext:context];
}

+ (NSArray*)tasksMatchingPredicate:(NSPredicate*)predicate inManagedObjectContext:(NSManagedObjectContext*)context {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Task"
											  inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	[fetchRequest setPredicate:predicate];
	
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

+ (NSSet *)keyPathsForValuesAffectingStatus {
	return [NSSet setWithObjects:@"completed", @"start", @"scheduled", @"dependsOn", nil];
}

- (NSNumber*)status {
	TaskStatus s;
	NSDate* now = [NSDate date];
	if ([self.completed compare:now] == NSOrderedAscending) {
		s = TaskStatusCompleted;
	} else if (([self.start compare:now] == NSOrderedDescending) || ([now compare:[self.dependsOn valueForKeyPath:@"@max.completed"]] == NSOrderedAscending)) {
		s = TaskStatusPending;
	} else if (!self.scheduled) {
		s = TaskStatusPossible;
	} else if ([self.scheduled compare:now] == NSOrderedDescending) {
		s = TaskStatusInactive;
	} else {
		s = TaskStatusActive;
	}
	NSLog(@"Status for %@: %d", self.title, s);
	return [NSNumber numberWithInt:s];
}

@end
