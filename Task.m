//
//  Task.m
//  TaskScheduler
//
//  Created by Bernhard Bauer on 03.01.10.
//  Copyright 2010 Black Sheep Software. All rights reserved.
//

#import "Task.h"


@interface Task (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber *)primitiveActive;
- (void)setPrimitiveActive:(NSNumber *)value;

- (NSNumber *)primitiveCompleted;
- (void)setPrimitiveCompleted:(NSNumber *)value;

- (NSNumber *)primitiveInactive;
- (void)setPrimitiveInactive:(NSNumber *)value;

- (NSNumber *)primitiveOverdue;
- (void)setPrimitiveOverdue:(NSNumber *)value;

- (NSNumber *)primitivePending;
- (void)setPrimitivePending:(NSNumber *)value;

@end

@implementation Task

@dynamic completedDate;
@dynamic dueDate;
@dynamic duration;
@dynamic eventUID;
@dynamic flagged;
@dynamic notes;
@dynamic priority;
@dynamic scheduledDate;
@dynamic startDate;
@dynamic taskUID;
@dynamic title;
@dynamic dependsOn;
@dynamic enables;
@dynamic active;
@dynamic completed;
@dynamic inactive;
@dynamic overdue;
@dynamic pending;


- (BOOL)evaluateSelfWithPredicateNamed:(NSString*)predicateName {
	NSManagedObjectModel* model = [[Task entityInContext:[self managedObjectContext]] managedObjectModel];
	NSDictionary* dict = [NSDictionary dictionaryWithObject:[NSDate date] forKey:@"NOW"];
	NSPredicate* predicate = [[model fetchRequestTemplateForName:predicateName] predicate];
	return [predicate evaluateWithObject:self substitutionVariables:dict];
}

- (NSNumber *)active {
    NSNumber * tmpValue;
    
    [self willAccessValueForKey:@"active"];
    tmpValue = [self primitiveActive];
	if (!tmpValue) {
		[self setPrimitiveActive:[NSNumber numberWithBool:[self evaluateSelfWithPredicateNamed:@"active"]]];
	}
    [self didAccessValueForKey:@"active"];
    
    return tmpValue;
}

- (NSNumber *)completed {
    NSNumber * tmpValue;
    
    [self willAccessValueForKey:@"completed"];
    tmpValue = [self primitiveCompleted];
	if (!tmpValue) {
		[self setPrimitiveCompleted:[NSNumber numberWithBool:[self evaluateSelfWithPredicateNamed:@"completed"]]];
	}
    [self didAccessValueForKey:@"completed"];
    
    return tmpValue;
}

- (NSNumber *)inactive {
    NSNumber * tmpValue;
    
    [self willAccessValueForKey:@"inactive"];
    tmpValue = [self primitiveInactive];
	if (!tmpValue) {
		[self setPrimitiveCompleted:[NSNumber numberWithBool:[self evaluateSelfWithPredicateNamed:@"inactive"]]];
	}
    [self didAccessValueForKey:@"inactive"];
    
    return tmpValue;
}

- (NSNumber *)overdue {
    NSNumber * tmpValue;
    
    [self willAccessValueForKey:@"overdue"];
    tmpValue = [self primitiveOverdue];
	if (!tmpValue) {
		[self setPrimitiveOverdue:[NSNumber numberWithBool:[self evaluateSelfWithPredicateNamed:@"overdue"]]];
	}
    [self didAccessValueForKey:@"overdue"];
    
    return tmpValue;
}

- (NSNumber *)pending {
    NSNumber * tmpValue;
    
    [self willAccessValueForKey:@"pending"];
    tmpValue = [self primitivePending];
	if (!tmpValue) {
		[self setPrimitivePending:[NSNumber numberWithBool:[self evaluateSelfWithPredicateNamed:@"pending"]]];
	}
    [self didAccessValueForKey:@"pending"];
    
    return tmpValue;
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
	if (self = [super initWithEntity:[Task entityInContext:context] insertIntoManagedObjectContext:context]) {
		
	}
	return self;
}

- (void)awakeFromFetch {
	self.completed = nil;
	self.pending = nil;
	self.active = nil;
	self.inactive = nil;
	self.overdue = nil;
	
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
	if ([keyPath isEqualToString:@"scheduledDate"]) {
		self.active = nil;
		self.inactive = nil;
	} else if ([keyPath isEqualToString:@"startDate"]) {
		self.pending = nil;
	} else if ([keyPath isEqualToString:@"completedDate"]) {
		self.completed = nil;
	} else if ([keyPath isEqualToString:@"dueDate"]) {
		self.overdue = nil;
	}
}


@end
