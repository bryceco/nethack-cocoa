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
 as published by the Free Software Foundation, version 2
 of the License.
 
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
	NSTextField * view = [[NSTextField alloc] initWithFrame:NSMakeRect(point.x, point.y, 10, 10)];
	NSColor * bgColor = [NSColor colorWithDeviceRed:1.0 green:1.0 blue:202/255.0 alpha:1.0];
	
	[view setStringValue:text];
	[view setBordered:YES];
	[view setBackgroundColor:bgColor];
	[view setEditable:NO];
	[view setSelectable:NO];
	[view sizeToFit];
	[view setRefusesFirstResponder:YES];
	
	// make sure it doesn't go off the screen
	NSRect viewRect = [view frame];
	NSRect screenRect = [[NSScreen mainScreen] visibleFrame];
	if ( viewRect.origin.x + viewRect.size.width > screenRect.origin.x + screenRect.size.width ) {
		// falls off right side
		viewRect.origin.x = screenRect.origin.x + screenRect.size.width - viewRect.size.width;
	}
	if ( viewRect.origin.y + viewRect.size.height > screenRect.origin.y + screenRect.size.height ) {
		// off top
		viewRect.origin.y = screenRect.origin.y + screenRect.size.height - viewRect.size.height;
	}
	if ( viewRect.origin.y < screenRect.origin.y ) {
		// off bottom
		viewRect.origin.y = screenRect.origin.y;
	}
	if ( viewRect.origin.x < screenRect.origin.x ) {
		// off left
		viewRect.origin.x = screenRect.origin.x;
	}
	[view setFrame:viewRect];
	
	
	if ( self = [super initWithContentRect:[view frame] styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreBuffered defer:YES] ) {
		[self setDelegate:self];
		[self setContentView:view];
		[self setOpaque:YES];
		[self setHasShadow:YES];
		[self setReleasedWhenClosed:NO];
		[self orderFront:self];
	}
	return self;
}

-(void)windowWillClose
{
}

@end
