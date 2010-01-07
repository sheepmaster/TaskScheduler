//
//  Task.h
//  TaskScheduler
//
//  Created by Bernhard Bauer on 03.01.10.
//  Copyright 2010 Black Sheep Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Task : NSManagedObject {

}

//@property NSString* title;
//@property NSString* notes;
//@property NSString* taskUID;

+ (Task*) taskWithTaskUID:(NSString*)uid inManagedObjectContext:(NSManagedObjectContext*)context;
+ (Task*) taskMatchingPredicate:(NSPredicate*)predicate inManagedObjectContext:(NSManagedObjectContext*)context;
+ (NSArray*)tasksMatchingPredicate:(NSPredicate*)predicate inManagedObjectContext:(NSManagedObjectContext*)context;
+ (NSArray*)allTasksInManagedObjectContext:(NSManagedObjectContext*)context;

- (id)initWithManagedObjectContext:(NSManagedObjectContext*)context;

@property (nonatomic, retain) NSDate * completed;
@property (nonatomic, retain) NSDate * due;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSString * eventUID;
@property (nonatomic, retain) NSNumber * flagged;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSNumber * priority;
@property (nonatomic, retain) NSDate * scheduled;
@property (nonatomic, retain) NSDate * start;
@property (nonatomic, retain) NSString * taskUID;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet* dependsOn;
@property (nonatomic, retain) NSSet* enables;
@property (readonly) NSSet* transitiveEnables;

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


@end
