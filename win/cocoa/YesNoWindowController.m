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

#import "YesNoWindowController.h"
#import "NhEventQueue.h"

@implementation YesNoWindowController

-(void)runModalWithQuestion:(NSString *)prompt choice1:(NSString *)choice1 choice2:(NSString *)choice2 defaultAnswer:(char)def onCancelSend:(char)cancelChar
{
	[question setStringValue:prompt];
	[button1 setTitle:choice1];
	[button2 setTitle:choice2];
	defaultAnswer = def;
	onCancelChar = cancelChar;
	
#if __MAC_OS_X_VERSION_MIN_REQUIRED < 1060
	NSButton *closeButton = [[self window] standardWindowButton:NSWindowCloseButton];
	if ( cancelChar ) {
		[closeButton setEnabled:YES];
	} else {
		[closeButton setEnabled:NO];
	}
#else
	// add/remove close button so ESC will/won't work
	NSUInteger style = [[self window] styleMask];
	if ( cancelChar ) {
		style |= NSWindowStyleMaskClosable;
	} else {
		style &= ~NSWindowStyleMaskClosable;
	}
	[[self window] setStyleMask:style];
#endif
	
	// disable default button
	[[self window] setDefaultButtonCell:nil];
	
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
	if ( [theEvent type] == NSEventTypeKeyDown ) {
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
	assert(onCancelChar);
	[[NhEventQueue instance] addKey:onCancelChar];
	return YES;
}

-(void)windowWillClose:(NSNotification *)notification
{
	[[NSApplication sharedApplication] stopModal];	
}

@end
