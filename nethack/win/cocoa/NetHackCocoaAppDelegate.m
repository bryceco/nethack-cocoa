//
//  NetHackCocoaAppDelegate.m
//  NetHackCocoa
//
//  Created by Dirk Zimmermann on 2/15/10.
//  Copyright 2010 Dirk Zimmermann. All rights reserved.
//

/*
 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

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
		"NetHack",
	};
	
	// create necessary directories
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	NSString *baseDirectory = [paths objectAtIndex:0];
	baseDirectory = [baseDirectory stringByAppendingPathComponent:@"NetHackCocoa"];
	if (![[NSFileManager defaultManager] fileExistsAtPath:baseDirectory]) {
		[[NSFileManager defaultManager] createDirectoryAtPath:baseDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
	}
	NSLog(@"baseDir %@", baseDirectory);
	setenv("NETHACKDIR", [baseDirectory UTF8String], 1);
	NSString *saveDirectory = [baseDirectory stringByAppendingPathComponent:@"save"];
	if (![[NSFileManager defaultManager] fileExistsAtPath:saveDirectory]) {
		[[NSFileManager defaultManager] createDirectoryAtPath:saveDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
	}
		
	// set plname (very important for save files and getlock)
	[[NSUserName() capitalizedString] getCString:plname maxLength:PL_NSIZ encoding:NSASCIIStringEncoding];
	
	// call NetHack
	unixmain(sizeof argv/sizeof argv[0], argv);
	
	// clean up thread pool
	[pool release];
}

@end
