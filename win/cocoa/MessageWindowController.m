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


#import "MessageWindowController.h"
#import "NhEventQueue.h"
#import "wincocoa.h"


#define RUN_MODAL	1


@implementation MessageWindowController

-(id)initWithMessage:(NSString *)message
{
	if ( self = [super initWithWindowNibName:@"MessageWindow"] ) {
		
		text = [message retain];

	}
	return self;
}

-(void)windowDidLoad
{
	// convert leading space to tab
	NSMutableString * mutable = [[text mutableCopyWithZone:NULL] autorelease];
	[mutable replaceOccurrencesOfString:@"\n  " withString:@"\n\t" options:0 range:NSMakeRange(0,[mutable length])];
	[mutable replaceOccurrencesOfString:@"\n* " withString:@"\n\t*" options:0 range:NSMakeRange(0,[mutable length])];
	
	[textField setEditable:YES];
	[textField setStringValue:mutable];
	[textField setEditable:NO];
	[textField setDrawsBackground:NO];
	[textField setBordered:NO];
	
	NSSize minimumSize = [[self window] frame].size;
	
	// size view  
	NSSize textSizeOrig = [textField frame].size;
	[textField sizeToFit];
	NSRect  textRect = [textField bounds];
	
	[textField setFrame:textRect];
	[textField setNeedsDisplay:YES];	
	
	// size containing window
	NSRect rc = [[self window] frame];
	rc.size.height += textRect.size.height - textSizeOrig.height;
	rc.size.width  += textRect.size.width  - textSizeOrig.width;
	if ( rc.size.height < minimumSize.height )
		rc.size.height = minimumSize.height;
	if ( rc.size.width < minimumSize.width )
		rc.size.width = minimumSize.width;
	
	[[self window] setFrame:rc display:NO];
}

// automatically dismiss if move key pressed
-(void)keyDown:(NSEvent *)theEvent
{
	if ( [theEvent type] == NSKeyDown ) {
		int key = [WinCocoa keyWithKeyEvent:theEvent];
		if ( key ) {
			[[NhEventQueue instance] addKey:key];
			[[self window] close];
			return;
		}
	}
	[super keyDown:theEvent];
}


+(void)messageWindowWithText:(NSString *)text
{
	MessageWindowController * win = [[MessageWindowController alloc] initWithMessage:text];
	[win showWindow:win];
	[win->textField scrollPoint:NSMakePoint(0,0)];
	
#if RUN_MODAL
	[[NSApplication sharedApplication] runModalForWindow:[win window]];
#endif
}

-(void)windowWillClose:(NSNotification *)notification
{
#if RUN_MODAL
	[[NSApplication sharedApplication] stopModal];
#endif
	
	[self autorelease];
}

-(void)dealloc
{
	[text release];
	[super dealloc];
}

@end
