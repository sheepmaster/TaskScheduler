//
//  URL.h
//  TaskScheduler
//
//  Created by Bernhard Bauer on 21.02.10.
//  Copyright 2010 Black Sheep Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface URL : NSManagedObject {

}

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * url;

@property (nonatomic, retain) Task * task;

@end
