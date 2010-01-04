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

+ (Task*) taskWithUID:(NSString*)uid inManagedObjectContext:(NSManagedObjectContext*)context;

- (id)initWithManagedObjectContext:(NSManagedObjectContext*)context;

@end

// coalesce these into one @interface Task (CoreDataGeneratedAccessors) section
@interface Task (CoreDataGeneratedAccessors)

@property (nonatomic, retain) NSDate * completed;
@property (nonatomic, retain) NSDate * due;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSNumber * durationScale;
@property (nonatomic, retain) NSString * eventUID;
@property (nonatomic, retain) NSNumber * flagged;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSNumber * priority;
@property (nonatomic, retain) NSDate * scheduled;
@property (nonatomic, retain) NSDate * start;
@property (nonatomic, retain) NSString * taskUID;
@property (nonatomic, retain) NSString * title;

@end
