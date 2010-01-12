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


- (BOOL)evaluateWithPredicateNamed:(NSString*)predicateName {
	NSManagedObjectModel* model = [[Task entityInContext:[self managedObjectContext]] managedObjectModel];
	NSDictionary* dict = [NSDictionary dictionaryWithObject:[NSDate date] forKey:@"NOW"];
	NSPredicate* predicate = [[model fetchRequestTemplateForName:predicateName] predicate];
	return [predicate evaluateWithObject:self substitutionVariables:dict];
}

- (void)updateCompleted {
	self.completed = [NSNumber numberWithBool:[self evaluateWithPredicateNamed:@"completed"]];
}

- (void)updateActive {
	self.active = [NSNumber numberWithBool:[self evaluateWithPredicateNamed:@"active"]];
	self.inactive = [NSNumber numberWithBool:[self evaluateWithPredicateNamed:@"inactive"]];	
}

- (NSDate*)completedDateOrDistantFuture {
	NSDate* date = self.completedDate;
	if (!date) {
		date = [NSDate distantFuture];
	}
	return date;
}

- (void)updatePending {
	NSDate* now = [NSDate date];
	NSPredicate* predicate = [NSPredicate predicateWithFormat:@"startDate > %@ OR ANY dependsOn.completedDateOrDistantFuture > %@", now, now];
	self.pending = [NSNumber numberWithBool:[predicate evaluateWithObject:self]];
}

- (void)updateOverdue {
	self.overdue = [NSNumber numberWithBool:[self evaluateWithPredicateNamed:@"overdue"]];
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

- (void)awakeFromInsert {
	[self awakeFromFetch];
}

- (void)awakeFromFetch {
	[self updateCompleted];
	[self updatePending];
	[self updateActive];
	[self updateOverdue];
	
	[self addObserver:self forKeyPath:@"completedDate" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
	[self addObserver:self forKeyPath:@"startDate" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
	[self addObserver:self forKeyPath:@"scheduledDate" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
	[self addObserver:self forKeyPath:@"dueDate" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
	[self addObserver:self forKeyPath:@"dependsOn" options:0 context:nil];
//	[self addObserver:self forKeyPath:@"dependsOn.completed" options:0 context:nil];
}

- (void)visitWithSet:(NSMutableSet*)set {
	if ([set member:self]) {
		return;
	}
	[set addObject:self];
	[self.enables makeObjectsPerformSelector:@selector(visitWithSet:) withObject:set];
}

- (NSSet*)transitiveEnables {
	NSMutableSet* set = [NSMutableSet set];
	[self visitWithSet:set];
	return set;
}

- (void)willTurnIntoFault {
	[self removeObserver:self forKeyPath:@"completedDate"];
	[self removeObserver:self forKeyPath:@"startDate"];
	[self removeObserver:self forKeyPath:@"scheduledDate"];
	[self removeObserver:self forKeyPath:@"dueDate"];
	[self removeObserver:self forKeyPath:@"dependsOn"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	NSLog(@"%@\t%@\tchange kind: %@\told: %@\tnew: %@", ((Task*)object).title, keyPath, [change objectForKey:NSKeyValueChangeKindKey], [change objectForKey:NSKeyValueChangeOldKey], [change objectForKey:NSKeyValueChangeNewKey]);
	if ([keyPath isEqualToString:@"scheduledDate"]) {
		[self updateActive];
	} else if ([keyPath isEqualToString:@"startDate"] || [keyPath isEqualToString:@"dependsOn"]) {
		[self updatePending];
	} else if ([keyPath isEqualToString:@"completedDate"]) {
		[self updateCompleted];
		[self.enables makeObjectsPerformSelector:@selector(updatePending)];
	} else if ([keyPath isEqualToString:@"dueDate"]) {
		[self updateOverdue];
	}
}


@end
