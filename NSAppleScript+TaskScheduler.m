//
//  NSAppleScript+TaskScheduler.m
//  TaskScheduler
//
//  Created by Bernhard Bauer on 15.01.10.
//  Copyright 2010 Black Sheep Software. All rights reserved.
//

#import "NSAppleScript+TaskScheduler.h"

#import <Carbon/Carbon.h>


@implementation NSAppleScript(TaskScheduler)

- (BOOL)callSubroutineNamed:(NSString*)subroutine withParameters:(NSArray*)parameterArray error:(NSDictionary**)error {
	NSAppleEventDescriptor* parameters = [NSAppleEventDescriptor listDescriptor];
	int i = 1;
	for (id parameter in parameterArray) {
		NSAppleEventDescriptor* descriptor;
		if ([parameter isKindOfClass: [NSString class]]) {
			descriptor = [NSAppleEventDescriptor descriptorWithString:parameter];
		} else if ([parameter isKindOfClass: [NSAppleEventDescriptor class]] ) {
			descriptor = parameter;
		} else {
			if (error) {
				*error = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"unrecognized parameter type for parameter %d in callSubroutineNamed:withParameters:error:", index] 
													 forKey:@"ParameterError"];
			}
			return NO; /* bad parameter */
			
		}
		[parameters insertDescriptor:descriptor atIndex:(i++)];
	}
	
	// create the AppleEvent target
	ProcessSerialNumber psn = {0, kCurrentProcess};
	NSAppleEventDescriptor* target = [NSAppleEventDescriptor descriptorWithDescriptorType:typeProcessSerialNumber
																					bytes:&psn
																				   length:sizeof(ProcessSerialNumber)];
	
	// create an NSAppleEventDescriptor with the script's method name to call,
	// this is used for the script statement: "on show_message(user_message)"
	// Note that the routine name must be in lower case.
	NSAppleEventDescriptor* handler = [NSAppleEventDescriptor descriptorWithString: [subroutine lowercaseString]];
	
	// create the event for an AppleScript subroutine,
	// set the method name and the list of parameters
	NSAppleEventDescriptor* event = [NSAppleEventDescriptor appleEventWithEventClass:kASAppleScriptSuite
																			 eventID:kASSubroutineEvent
																	targetDescriptor:target
																			returnID:kAutoGenerateReturnID
																	   transactionID:kAnyTransactionID];
	[event setParamDescriptor:handler forKeyword:keyASSubroutineName];
	[event setParamDescriptor:parameters forKeyword:keyDirectObject];
	
	// call the event in AppleScript
	return [self executeAppleEvent:event error:error];
}

@end
