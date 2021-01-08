//
//  InputWindowController.m
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

#import "InputWindowController.h"
#import "NhTextInputEvent.h"
#import "NhEventQueue.h"

@implementation InputWindowController

-(void)runModalWithPrompt:(NSString *)prompt
{
	[promptField setStringValue:prompt];
	[inputField setStringValue:@""];
	[[NSApplication sharedApplication] runModalForWindow:[self window]];
}

-(IBAction)doAccept:(id)sender
{
	NSString * text = [inputField stringValue];
	NhTextInputEvent * e = [[NhTextInputEvent alloc] initWithText:text];
	[[NhEventQueue instance] addEvent:e];
	[[self window] close];
}

-(IBAction)doCancel:(id)sender
{
	NSString * text = @"\033";
	NhTextInputEvent * e = [[NhTextInputEvent alloc] initWithText:text];
	[[NhEventQueue instance] addEvent:e];	
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
