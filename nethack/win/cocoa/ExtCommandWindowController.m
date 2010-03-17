//
//  ExtCommandWindowController.m
//  NetHackCocoa
//
//  Created by Bryce on 2/19/10.
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

#import "ExtCommandWindowController.h"
#import "NhEventQueue.h"
#import "NhTextInputEvent.h"

#include "hack.h"
#include "func_tab.h"


@implementation ExtCommandWindowController


-(void)runModal
{
	if ( [[menuView subviews] count] == 0 ) {

		// create window contents on first run
		CGFloat itemIndent	= 25.0;
		NSRect  viewRect = [menuView bounds];
		
		CGFloat yPos = 10.0;
		for ( int i = 0; extcmdlist[i].ef_txt; ++i ) {
			
			if ( extcmdlist[i].ef_txt[0] == '?' )
				// skip help command
				continue;
			
			NSRect rect = NSMakeRect(itemIndent, yPos, viewRect.size.width, 10 );
			NSButton * button = [[NSButton alloc] initWithFrame:rect];	
			[button setButtonType:NSRadioButton];
			[button setBordered:NO];
			NSString * key = [NSString stringWithFormat:@"%c", extcmdlist[i].ef_txt[0]];
			[button setKeyEquivalent:key];
			[button setTarget:self];
			[button setAction:@selector(buttonClick:)];
			[button setTag:i];	// index of command
			NSString * text = [NSString stringWithFormat:@"%s -- %s", extcmdlist[i].ef_txt, extcmdlist[i].ef_desc];
			[button setTitle:text];
			[button sizeToFit];
			[menuView addSubview:button];
			
			rect = [button bounds];
			yPos += rect.size.height + 3;
			[button release];
		}
				
		// get max item width
		CGFloat width = 0;
		for ( NSView * view in [menuView subviews] ) {
			NSRect rc = [view frame];
			if ( rc.origin.x + rc.size.width > width )
				width = rc.origin.x + rc.size.width;
		}
		
		NSSize viewSizeOrig = [menuView frame].size;
		
		// size view  
		viewRect.size.height = yPos;
		viewRect.size.width  = width + 10;
		[menuView setFrame:viewRect];
		[menuView scrollPoint:NSMakePoint(0,0)];
		[menuView setNeedsDisplay:YES];	
		
		// size containing window
		NSRect rc = [[self window] frame];
		rc.size.height += viewRect.size.height - viewSizeOrig.height;
		rc.size.width  += viewRect.size.width  - viewSizeOrig.width;
		[[self window] setFrame:rc display:YES];
	}

	// initialize button states
	[acceptButton setEnabled:NO];
	for ( NSButton * button in [menuView subviews] ) {
		[button setState:NSOffState];
	}

	[[NSApplication sharedApplication] runModalForWindow:[self window]];
}


-(void)buttonClick:(id)sender
{
	NSButton * button = sender;
	// unselect any other items
	for ( NSButton * item in [menuView subviews] ) {
		if ( [item class] == [button class]  &&  item != button )  {
			[item setState:NSOffState];
		}
	}
	[acceptButton setEnabled:YES];
}

-(void)doAccept:(id)sender
{
	// get list of selected tags
	for ( NSButton * button in [menuView subviews] ) {
		// add selected item
		if ( [button state] == NSOnState ) {
			int tag = [button tag];
			NSString * cmd = [NSString stringWithUTF8String:extcmdlist[tag].ef_txt];
			NhTextInputEvent * e = [[NhTextInputEvent alloc] initWithText:cmd];
			[[NhEventQueue instance] addEvent:e];
			[e release];
			break;
		}
	}
	[[self window] close];
}

-(void)doCancel:(id)sender
{
	NhTextInputEvent * e = [[NhTextInputEvent alloc] initWithText:@""];
	[[NhEventQueue instance] addEvent:e];
	[e release];
	[[self window] close];
}

-(BOOL)windowShouldClose:(id)sender
{
	// user pressed close button in title bar
	[self doCancel:sender];
	return YES;
}

-(void)windowWillClose:(NSNotification *)notification
{
	[[NSApplication sharedApplication] stopModal];	
}

@end
