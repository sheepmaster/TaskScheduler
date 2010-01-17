//
//  TaskCell.h
//  TaskScheduler
//
//  Created by Bernhard Bauer on 17.01.10.
//  Copyright 2010 Black Sheep Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Task;

@interface TaskCell : NSTextFieldCell {
	Task* task;
}

@property(retain) Task* task;

@end
