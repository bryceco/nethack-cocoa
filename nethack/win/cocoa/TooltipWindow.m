//
//  TooltipWindow.m
//  NetHackCocoa
//
//  Created by Bryce on 2/21/10.
//  Copyright 2010 Bryce Cogswell. All rights reserved.
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
		[self setDelegate:self];
		[self setContentView:view];
		[self setOpaque:YES];
		[self setHasShadow:YES];
		[self setReleasedWhenClosed:YES];
		[self orderFront:self];
		
		NSLog(@"tooltip create\n");
	}
	return self;
}

-(void)windowWillClose
{
}

-(void)dealloc
{
	NSLog(@"tooltip destroy\n");
	[super dealloc];
}

@end
