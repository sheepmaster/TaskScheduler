//
//  StatusChange.h
//  TaskScheduler
//
//  Created by Bernhard Bauer on 12.01.10.
//  Copyright 2010 Black Sheep Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Task;

@interface StatusChange : NSManagedObject {

}

@property (nonatomic, retain) Task * task;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * status;

+ (StatusChange*)nextStatusChangeInContext:(NSManagedObjectContext*)context;

@end
