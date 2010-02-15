//
//  NetHackCocoaAppDelegate.h
//  NetHackCocoa
//
//  Created by Dirk Zimmermann on 2/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MainViewController;

@interface NetHackCocoaAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	NSThread *netHackThread;
	MainViewController *mainViewController;
}

@property (assign) IBOutlet NSWindow *window;

@end
