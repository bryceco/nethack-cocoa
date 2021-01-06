//
//  DirectionWindowController.m
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

#import "DirectionWindowController.h"
#import "NhEventQueue.h"
#import "wincocoa.h"

@implementation DirectionWindowController

-(void)runModalWithPrompt:(NSString *)prompt
{
	[[self window] setTitle:prompt];
	[[NSApplication sharedApplication] runModalForWindow:[self window]];
}

-(IBAction)chooseDirection:(id)sender;
{
	NSButton * button = (id)sender;
	NSString * keyEquiv = [button keyEquivalent];

	int key = [keyEquiv characterAtIndex:0];
	int mod = [button keyEquivalentModifierMask];
	if ( mod & NSEventModifierFlagShift ) {
		if ( key == '.' )
			key = '>';
		else if ( key == ',' )
			key = '<';
	}
	[[NhEventQueue instance] addKey:key];
	[[self window] close];
}



- (void)keyDown:(NSEvent *)theEvent 
{
	const char directions[] = "bjnhlyku<.>";
	if ( [theEvent type] == NSEventTypeKeyDown ) {
		char key = [WinCocoa keyWithKeyEvent:theEvent];
		if ( key ) {
			if ( strchr( directions, key ) != NULL ) {
				// user typed a valid direction
				[[NhEventQueue instance] addKey:key];
				[[self window] close];
			}
		}
	}
}

-(BOOL)windowShouldClose:(id)sender
{
	[[NhEventQueue instance] addKey:'\033'];
	return YES;
}

-(void)windowWillClose:(id)sender
{
	[[NSApplication sharedApplication] stopModal];	
}

@end
