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
@dynamic status;


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

+ (NSEntityDescription*)entityInContext:(NSManagedObjectContext*)context {
	return [NSEntityDescription entityForName:@"Task" inManagedObjectContext:context];
}

+ (NSArray*)tasksMatchingPredicate:(NSPredicate*)predicate inManagedObjectContext:(NSManagedObjectContext*)context {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [self entityInContext:context];
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
	if (self = [super initWithEntity:[self entityInContext:context] insertIntoManagedObjectContext:context]) {
		
	}
	return self;
}

- (void)awakeFromFetch {
	[self refreshStatus];
	[self addObserver:self forKeyPath:@"completed" options:0 context:nil];
	[self addObserver:self forKeyPath:@"start" options:0 context:nil];
	[self addObserver:self forKeyPath:@"scheduled" options:0 context:nil];
	[self addObserver:self forKeyPath:@"dependsOn" options:0 context:nil];
//	[self addObserver:self forKeyPath:@"dependsOn.completed" options:0 context:nil];
}

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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	[self refreshStatus];
}

+ (NSSet *)keyPathsForValuesAffectingStatus {
	return [NSSet setWithObjects:@"completed", @"start", @"scheduled", @"dependsOn", nil];
}

- (void)refreshStatus {
	NSManagedObjectModel* model = [[Task entityInContext:[self managedObjectContext]] managedObjectModel];
	NSDictionary* dict = [NSDictionary dictionaryWithObject:[NSDate date] forKey:@"NOW"];
	NSPredicate* completedPredicate = [[model fetchRequestTemplateForName:@"completed"] predicate];
	NSPredicate* pendingPredicate = [[model fetchRequestTemplateForName:@"pending"] predicate];
	NSPredicate* activePredicate = [[model fetchRequestTemplateForName:@"active"] predicate];
	NSPredicate* inactivePredicate = [[model fetchRequestTemplateForName:@"inactive"] predicate];
	TaskStatus s;
	if ([completedPredicate evaluateWithObject:self substitutionVariables:dict]) {
		s = TaskStatusCompleted;
	} else if ([pendingPredicate evaluateWithObject:self substitutionVariables:dict]) {
		s = TaskStatusPending;
	} else if ([activePredicate evaluateWithObject:self substitutionVariables:dict]) {
		s = TaskStatusActive;
	} else if ([inactivePredicate evaluateWithObject:self substitutionVariables:dict]) {
		s = TaskStatusInactive;
	} else {
		s = TaskStatusPossible;
	}
	self.status = [NSNumber numberWithInt:s];
}

@end
