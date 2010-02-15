//
//  NetHackCocoaAppDelegate.m
//  NetHackCocoa
//
//  Created by Dirk Zimmermann on 2/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NetHackCocoaAppDelegate.h"
#import "wincocoa.h"

#include <sys/stat.h>

extern int unixmain(int argc, char **argv);

@implementation NetHackCocoaAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	netHackThread = [[NSThread alloc] initWithTarget:self selector:@selector(netHackMainLoop:) object:nil];
	[netHackThread start];
}

- (void) netHackMainLoop:(id)arg {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	char *argv[] = {
		"NetHack"	
	};
	
	// create necessary directories
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *baseDirectory = [paths objectAtIndex:0];
	baseDirectory = [baseDirectory stringByAppendingPathComponent:@"NetHackCocoa"];
	if (![[NSFileManager defaultManager] fileExistsAtPath:baseDirectory]) {
		mkdir([baseDirectory cStringUsingEncoding:NSASCIIStringEncoding], 0770);
	}
	NSLog(@"baseDir %@", baseDirectory);
	setenv("NETHACKDIR", [baseDirectory cStringUsingEncoding:NSASCIIStringEncoding], 1);
	NSString *saveDirectory = [baseDirectory stringByAppendingPathComponent:@"save"];
	if (![[NSFileManager defaultManager] fileExistsAtPath:saveDirectory]) {
		mkdir([saveDirectory cStringUsingEncoding:NSASCIIStringEncoding], 0770);
	}
		
	// set plname (very important for save files and getlock)
	[[NSUserName() capitalizedString] getCString:plname maxLength:PL_NSIZ encoding:NSASCIIStringEncoding];
	
	// call NetHack
	unixmain(1, argv);
	
	// clean up thread pool
	[pool release];
}

@end
