//
//  MessageWindowController.m
//  NetHackCocoa
//
//  Created by Bryce on 2/17/10.
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


#import "MessageWindowController.h"


@implementation MessageWindowController

-(void)runModalWithMessage:(NSString *)text
{
	// convert leading space to tab
	NSMutableString * mutable = [text mutableCopyWithZone:NULL];
	[mutable replaceOccurrencesOfString:@"\n " withString:@"\n\t" options:0 range:NSMakeRange(0,[mutable length])];

	NSRect origRect = [textField frame];
	[textField setStringValue:mutable];
	[textField sizeToFit];
	NSRect newRect = [textField frame];

	NSRect f = [[self window] frame];
	f.size.width  += newRect.size.width - origRect.size.width;
	f.size.height += newRect.size.height - origRect.size.height;
	[[self window] setFrame:f display:NO];
	[textField setFrame:newRect];

	[[NSApplication sharedApplication] runModalForWindow:[self window]];
}

-(void)windowWillClose:(NSNotification *)notification
{
	[[NSApplication sharedApplication] stopModal];	
}

@end
