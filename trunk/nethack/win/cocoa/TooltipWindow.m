//
//  TooltipWindow.m
//  NetHackCocoa
//
//  Created by Bryce on 2/21/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "TooltipWindow.h"


@implementation TooltipWindow

-(id)initWithText:(NSString *)text location:(NSPoint)point
{
	NSTextField * view = [[[NSTextField alloc] initWithFrame:NSMakeRect(point.x, point.y, 10, 10)] autorelease];
	NSColor * bgColor = [NSColor colorWithDeviceRed:1.0 green:1.0 blue:202/255.0 alpha:1.0];
	
	[view setStringValue:text];
	[view setBordered:YES];
	[view setBackgroundColor:bgColor];
	[view setEditable:NO];
	[view setSelectable:NO];
	[view sizeToFit];
	[view setRefusesFirstResponder:YES];
	
	if ( self = [super initWithContentRect:[view frame] styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:YES] ) {
		[self setContentView:view];
		[self setOpaque:YES];
		[self setHasShadow:YES];
		[self setReleasedWhenClosed:YES];
		[self orderFront:self];
	}
	return self;
}


@end
