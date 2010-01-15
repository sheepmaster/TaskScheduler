//
//  NSAppleScript+TaskScheduler.h
//  TaskScheduler
//
//  Created by Bernhard Bauer on 15.01.10.
//  Copyright 2010 Black Sheep Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSAppleScript(TaskScheduler)

- (BOOL)callSubroutineNamed:(NSString*)subroutine withParameters:(NSArray*)parameters error:(NSDictionary**)error;

@end
