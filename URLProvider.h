//
//  URLProvider.h
//  TaskScheduler
//
//  Created by Bernhard Bauer on 21.02.10.
//  Copyright 2010 Black Sheep Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class URL;

@interface URLProvider : NSObject {

}

- (NSArray*)completionsForString:(NSString*)string;
- (URL*)urlForString:(NSString*)string;


@end
