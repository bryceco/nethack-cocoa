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

-(void)runModalWithQuestion:(NSString *)prompt choice1:(NSString *)choice1 choice2:(NSString *)choice2 defaultAnswer:(char)def canCancel:(BOOL)canCancel
{
	[question setStringValue:prompt];
	[button1 setTitle:choice1];
	[button2 setTitle:choice2];
	
	// add/remove close button so ESC will/won't work
	NSUInteger style = [[self window] styleMask];
	if ( canCancel ) {
		style |= NSClosableWindowMask;
	} else {
		style &= ~NSClosableWindowMask;
	}
	[[self window] setStyleMask:style];

	// disable default button
	[[self window] setDefaultButtonCell:nil];
	defaultAnswer = 0;		
	
	if ( def ) {
		// if default value is present then set a button as using default
		if ( tolower( [choice1 characterAtIndex:0] ) == def ) {
			[[self window] setDefaultButtonCell:[button1 cell]];
		} 
		if ( tolower( [choice2 characterAtIndex:0] ) == def ) {
			[[self window] setDefaultButtonCell:[button2 cell]];
		}
	}
	
	[[NSApplication sharedApplication] runModalForWindow:[self window]];	
}

- (void)keyDown:(NSEvent *)theEvent
{
	if ( [theEvent type] == NSKeyDown ) {
		NSString * text = [theEvent charactersIgnoringModifiers];
		if ( [text isEqualToString:[[[button1 title] substringToIndex:1] lowercaseString]] ) {
			[self performButton:button1];
			return;
		}
		if ( [text isEqualToString:[[[button2 title] substringToIndex:1] lowercaseString]] ) {
			[self performButton:button2];
			return;
		}
		if ( defaultAnswer && [text isEqualToString:@"\r"] ) {
			[[NhEventQueue instance] addKey:defaultAnswer];
			[[self window] close];
			return;
		}
	}
	[super keyDown:theEvent];
}


-(IBAction)performButton:(id)sender
{
	NSButton * button = sender;
	
	char key = tolower( [[button title] characterAtIndex:0] );
	[[NhEventQueue instance] addKey:key];
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
