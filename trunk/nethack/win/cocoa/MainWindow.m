//
//  MainWindow.m
//  NetHackCocoa
//
//  Created by Bryce on 3/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MainWindow.h"


@implementation MainWindow

- (void)sendEvent:(NSEvent *)event
{
	if ( [event type] == NSKeyDown || [event type] == NSKeyUp ) {
		NSLog( @"MainWindow sendEvent: %@, char = %x\n", event, [[event characters] characterAtIndex:0] );
	}
	
	[super sendEvent:event];
}

@end
