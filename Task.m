//
//  Task.m
//  TaskScheduler
//
//  Created by Bernhard Bauer on 03.01.10.
//  Copyright 2010 Black Sheep Software. All rights reserved.
//

#import "Task.h"
#import "StatusChange.h"

@interface Task (CoreDataGeneratedPrimitiveAccessors)

- (NSDate *)primitiveEffectiveDueDate;
- (void)setPrimitiveEffectiveDueDate:(NSDate *)value;

- (NSDate *)primitiveEffectiveStartDate;
- (void)setPrimitiveEffectiveStartDate:(NSDate *)value;

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
@dynamic statusChanges;
@dynamic effectiveStartDate;
@dynamic effectiveDueDate;

- (id)copyWithZone:(NSZone*)zone {
	return [self retain];
}

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

- (NSDate*)calculateEffectiveDueDate {
	NSDate* minDate = self.dueDate ? self.dueDate : [NSDate distantFuture];
	for (Task* task in self.enables) {
		NSDate* date = [task.effectiveDueDate dateByAddingTimeInterval:-[task.duration doubleValue]];
		if ([minDate compare:date] == NSOrderedDescending) {
			minDate = date;
		}
		if (task.scheduledDate) {
			if ([minDate compare:task.scheduledDate] == NSOrderedDescending) {
				minDate = task.scheduledDate;
			}
		}
	}
	return minDate;
}

- (void)updateEffectiveDueDate {
	NSDate* newValue = [self calculateEffectiveDueDate];
	if (![newValue isEqualToDate:[self primitiveEffectiveDueDate]]) {
		[self willChangeValueForKey:@"effectiveDueDate"];
		[self setPrimitiveEffectiveDueDate:newValue];
		[self didChangeValueForKey:@"effectiveDueDate"];
	}
}

- (NSDate*)calculateEffectiveStartDate {
	NSDate* maxDate = self.startDate ? self.startDate : [NSDate distantPast];
	for (Task* task in self.dependsOn) {
		if (task.completedDate) {
			if ([maxDate compare:task.completedDate] == NSOrderedAscending) {
				maxDate = task.completedDate;
			}
		} else if (task.scheduledDate) {
			NSDate* date = [task.scheduledDate dateByAddingTimeInterval:[task.duration doubleValue]];
			if ([maxDate compare:date] == NSOrderedAscending) {
				maxDate = date;
			}
		} else {
			NSDate* date = [task.effectiveStartDate dateByAddingTimeInterval:[task.duration doubleValue]];
			if ([maxDate compare:date] == NSOrderedAscending) {
				maxDate = date;
			}
		}
	}
	return maxDate;
}

- (void)updateEffectiveStartDate {
	NSDate* newValue = [self calculateEffectiveStartDate];
	if (![newValue isEqualToDate:[self primitiveEffectiveStartDate]]) {
		[self willChangeValueForKey:@"effectiveStartDate"];
		[self setPrimitiveEffectiveStartDate:newValue];
		[self didChangeValueForKey:@"effectiveStartDate"];
	}
}


+ (Task*) taskWithTaskUID:(NSString*)uid inManagedObjectContext:(NSManagedObjectContext*)context {
	NSPredicate* predicateTemplate = [NSPredicate predicateWithFormat:@"taskUID == $UID"];
	NSPredicate* predicate = [predicateTemplate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObject:uid forKey:@"UID"]];
	return [self taskMatchingPredicate:predicate inManagedObjectContext:context];
}

+ (Task*) taskMatchingPredicate:(NSPredicate*)predicate inManagedObjectContext:(NSManagedObjectContext*)context {
	NSArray* tasks = [self tasksMatchingPredicate:predicate inManagedObjectContext:context];
	if ([tasks count] != 1) {
		NSLog(@"Found %d tasks matching predicate %@", [tasks count], predicate);
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

- (StatusChange*)statusChange:(NSString*)status {
	NSPredicate* predicate = [NSPredicate predicateWithFormat:@"status == $STATUS"];
	NSDictionary* dict = [NSDictionary dictionaryWithObject:status forKey:@"STATUS"];
							
	NSSet* set = [self.statusChanges filteredSetUsingPredicate:[predicate predicateWithSubstitutionVariables:dict]];
	if ([set count] != 1) {
//		NSLog(@"Found %d status changes \"%@\" for object %@", [set count], status, self.title);
	}
	return [set anyObject];
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
	[self updateEffectiveDueDate];
	[self updateEffectiveStartDate];
	
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

- (void)dateForStatus:(NSString*)status changedFrom:(NSDate*)oldDate to:(NSDate*)newDate {
	NSManagedObjectContext* context = [self managedObjectContext];
	StatusChange* change =  [self statusChange:status];
	if (change && [oldDate isKindOfClass:[NSNull class]]) {
		NSLog(@"Found superfluous change of %@ for %@", status, self.title);
	}
	if ([newDate isKindOfClass:[NSNull class]] || ([newDate compare:[NSDate date]] == NSOrderedAscending)) {
		if (change) {
			[change.task removeDependsOnObject:change];
			[context deleteObject:change];
		}
	} else {
		if (!change) {
			NSEntityDescription* entity = [NSEntityDescription entityForName:@"StatusChange" inManagedObjectContext:context];
			change = [[StatusChange alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
			change.status = status;
			[self addStatusChangesObject:change];
			[change autorelease];
		}
		change.date = newDate;
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//	NSLog(@"%@\t%@\tchange kind: %@\told: %@\tnew: %@", ((Task*)object).title, keyPath, [change objectForKey:NSKeyValueChangeKindKey], [change objectForKey:NSKeyValueChangeOldKey], [change objectForKey:NSKeyValueChangeNewKey]);
	if ([keyPath isEqualToString:@"scheduledDate"]) {
		[self dateForStatus:@"scheduled" 
				changedFrom:[change objectForKey:NSKeyValueChangeOldKey] 
						 to:[change objectForKey:NSKeyValueChangeNewKey]];
		[self updateActive];
		[self.dependsOn makeObjectsPerformSelector:@selector(updateEffectiveDueDate)];
		[self.enables makeObjectsPerformSelector:@selector(updateEffectiveStartDate)];
	} else if ([keyPath isEqualToString:@"startDate"]) {
		[self dateForStatus:@"start" 
				changedFrom:[change objectForKey:NSKeyValueChangeOldKey] 
						 to:[change objectForKey:NSKeyValueChangeNewKey]];
		[self updatePending];
		[self updateEffectiveStartDate];
	} else if ([keyPath isEqualToString:@"effectiveStartDate"]) {
		[self.enables makeObjectsPerformSelector:@selector(updateEffectiveStartDate)];
	} else if ([keyPath isEqualToString:@"dependsOn"]) {
		[self updatePending];
		[self updateEffectiveDueDate];
	} else if ([keyPath isEqualToString:@"enables"]) {
		[self updateEffectiveStartDate];
	} else if ([keyPath isEqualToString:@"completedDate"]) {
		[self dateForStatus:@"completed" 
				changedFrom:[change objectForKey:NSKeyValueChangeOldKey] 
						 to:[change objectForKey:NSKeyValueChangeNewKey]];
		[self updateCompleted];
		[self.enables makeObjectsPerformSelector:@selector(updatePending)];
		[self.enables makeObjectsPerformSelector:@selector(updateEffectiveStartDate)];
	} else if ([keyPath isEqualToString:@"dueDate"]) {
		[self dateForStatus:@"due" 
				changedFrom:[change objectForKey:NSKeyValueChangeOldKey] 
						 to:[change objectForKey:NSKeyValueChangeNewKey]];
		[self updateOverdue];
		[self updateEffectiveDueDate];
	} else if ([keyPath isEqualToString:@"effectiveDueDate"]) {
		[self.dependsOn makeObjectsPerformSelector:@selector(updateEffectiveDueDate)];
	}
}

// !completed && (overdue || pending && active)

@end
