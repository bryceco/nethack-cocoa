//
//  YesNoWindowController.m
//  NetHackCocoa
//
//  Created by Bryce on 2/18/10.
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

#import "YesNoWindowController.h"
#import "NhEventQueue.h"

@implementation YesNoWindowController

-(void)runModalWithQuestion:(NSString *)prompt choice1:(NSString *)choice1 choice2:(NSString *)choice2 canCancel:(BOOL)canCancel
{
	[question setStringValue:prompt];
	[button1 setTitle:choice1];
	[button2 setTitle:choice2];
	[button1 setKeyEquivalent:[[choice1 substringToIndex:1] lowercaseString]];
	[button2 setKeyEquivalent:[[choice2 substringToIndex:1] lowercaseString]];
	
	// add/remove close button so ESC will/won't work
	NSUInteger style = [[self window] styleMask];
	if ( canCancel ) {
		style |= NSClosableWindowMask;
	} else {
		style &= ~NSClosableWindowMask;
	}
	[[self window] setStyleMask:style];
	
	[[NSApplication sharedApplication] runModalForWindow:[self window]];	
}

-(IBAction)performButton:(id)sender
{
	NSButton * button = sender;
	NSString * keyEquiv = [button keyEquivalent];
	if ( keyEquiv && [keyEquiv length] ) {
		char key = [keyEquiv characterAtIndex:0];
		[[NhEventQueue instance] addKey:key];
	} else {
		[[NhEventQueue instance] addKey:'\033'];
	}
	[[self window] close];
}

-(BOOL)windowShouldClose:(id)sender
{
	[[NhEventQueue instance] addKey:'\033'];
	return YES;
}

-(void)windowWillClose:(NSNotification *)notification
{
	[[NSApplication sharedApplication] stopModal];	
}

@end
