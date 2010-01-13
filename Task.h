//
//  Task.h
//  TaskScheduler
//
//  Created by Bernhard Bauer on 03.01.10.
//  Copyright 2010 Black Sheep Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class StatusChange;

@interface Task : NSManagedObject {

}

@property (nonatomic, retain) NSDate * completedDate;
@property (readonly) NSDate* completedDateOrDistantFuture;
@property (nonatomic, retain) NSNumber * completed;
@property (nonatomic, retain) NSDate * dueDate;
@property (nonatomic, retain) NSNumber * overdue;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSString * eventUID;
@property (nonatomic, retain) NSNumber * flagged;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSNumber * priority;
@property (nonatomic, retain) NSDate * scheduledDate;
@property (nonatomic, retain) NSNumber * active;
@property (nonatomic, retain) NSNumber * inactive;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSNumber * pending;
@property (nonatomic, retain) NSString * taskUID;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet* dependsOn;
@property (nonatomic, retain) NSSet* enables;
@property (readonly) NSSet* transitiveEnables;
@property (nonatomic, retain) NSSet* statusChanges;


+ (NSEntityDescription*)entityInContext:(NSManagedObjectContext*)context;
+ (Task*) taskWithTaskUID:(NSString*)uid inManagedObjectContext:(NSManagedObjectContext*)context;
+ (Task*) taskMatchingPredicate:(NSPredicate*)predicate inManagedObjectContext:(NSManagedObjectContext*)context;
+ (NSArray*)tasksMatchingPredicate:(NSPredicate*)predicate inManagedObjectContext:(NSManagedObjectContext*)context;
+ (NSArray*)allTasksInManagedObjectContext:(NSManagedObjectContext*)context;

- (StatusChange*)statusChange:(NSString*)status;

- (id)initWithManagedObjectContext:(NSManagedObjectContext*)context;

- (BOOL)evaluateWithPredicateNamed:(NSString*)predicateName;
- (void)updateCompleted;
- (void)updateActive;
- (void)updatePending;
- (void)updateOverdue;

- (void)dateForStatus:(NSString*)status changedFrom:(NSDate*)oldDate to:(NSDate*)newDate;

@end

// coalesce these into one @interface Task (CoreDataGeneratedAccessors) section
@interface Task (CoreDataGeneratedAccessors)
- (void)addDependsOnObject:(NSManagedObject *)value;
- (void)removeDependsOnObject:(NSManagedObject *)value;
- (void)addDependsOn:(NSSet *)value;
- (void)removeDependsOn:(NSSet *)value;

- (void)addEnablesObject:(NSManagedObject *)value;
- (void)removeEnablesObject:(NSManagedObject *)value;
- (void)addEnables:(NSSet *)value;
- (void)removeEnables:(NSSet *)value;

- (void)addStatusChangesObject:(NSManagedObject *)value;
- (void)removeStatusChangesObject:(NSManagedObject *)value;
- (void)addStatusChanges:(NSSet *)value;
- (void)removeStatusChanges:(NSSet *)value;

@end
