//
//  MenuWindowController.m
//  NetHackCocoa
//
//  Created by Bryce on 2/16/10.
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


#import "MenuWindowController.h"
#import "NhMenuWindow.h"
#import "NhItem.h"
#import "NhItemGroup.h"
#import "TileSet.h"
#import "NSString+Z.h"
#import "NhEventQueue.h"
#import "TileSet.h"

@implementation MenuWindowController


-(void)buttonClick:(id)sender
{
	NSButton * button = sender;
	switch ( [menuParams how] ) {

		case PICK_NONE:
			break;
			
		case PICK_ONE:
			{
				// unselect any other items
				for ( NSButton * item in [menuView subviews] ) {
					if ( [item class] == [button class]  &&  item != button )  {
						[item setState:NSOffState];
					}
				}
			}
			break;
	
		case PICK_ANY:
			break;
		
		default:
			break;
	}
	[acceptButton setEnabled:YES];
}

-(void)doAccept:(id)sender
{
	char firstSelection = '\0';
	// get list of selected tags
	for ( NSButton * button in [menuView subviews] ) {
		if ( [button class] == [NSButton class]  &&  [button state] == NSOnState )  {
			// add selected item
			char key = [button tag];
			NhItem * item = [itemDict objectForKey:[NSNumber numberWithInt:key]];
			assert(item);
			[menuParams.selected addObject:item];
			if ( firstSelection == 0 )
				firstSelection = key;
		}
	}
	
	switch ( [menuParams how] ) {
		case PICK_NONE:
			break;
		case PICK_ONE:
			[[NhEventQueue instance] addKey:firstSelection];
			break;
		case PICK_ANY:
			[[NhEventQueue instance] addKey:menuParams.selected.count];
			break;
	}
	[[self window] close];
}

-(void)doCancel:(id)sender
{
	if ( [menuParams how] != PICK_NONE ) {
		[[NhEventQueue instance] addKey:-1];
	}
	[[self window] close];	
}

-(BOOL)windowShouldClose:(id)sender
{
	[self doCancel:sender];
	return YES;
}


-(void)windowWillClose:(NSNotification *)notification
{
	if ( [menuParams how] != PICK_NONE ) {
		[[NSApplication sharedApplication] stopModal];
	}
	[self autorelease];
}



- (id)initWithMenu:(NhMenuWindow *)menu
{
	if ( self = [super initWithWindowNibName:@"MenuWindow"] ) {
		menuParams = [menu retain];
		itemDict = [[NSMutableDictionary dictionaryWithCapacity:10] retain];
	}
	return self;
}

-(void)dealloc
{
	[menuParams release];
	[itemDict release];
	[super dealloc];
}


-(void)windowDidLoad
{
	NSSize		minimumSize = [[self window] frame].size;
	NSFont	*	groupFont	= [NSFont labelFontOfSize:15];
	int			how			= [menuParams how];
	char	*	nextKey		= "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
	
	// add new labels
	CGFloat groupIndent	= 25.0;
	CGFloat itemIndent	= 40.0;
	NSRect  viewRect = [menuView bounds];

	CGFloat yPos = 0.0;
	for ( NhItemGroup * group in [menuParams itemGroups] ) {
		
		NSRect rect = NSMakeRect(groupIndent, yPos, viewRect.size.width, 10 );
		NSTextField * label = [[NSTextField alloc] initWithFrame:rect];
		[label setStringValue:[group title]];
		[label setEditable:NO];
		[label setDrawsBackground:NO];
		[label setBordered:NO];
		[label setFont:groupFont];
		[label sizeToFit];
		[menuView addSubview:label];
		yPos += [label bounds].size.height;
		[label release];

		for ( NhItem * item in [group items] ) {

			// get keyboard shortcut for item
			int keyEquiv = [item inventoryLetter];
			if ( keyEquiv == 0 )
				keyEquiv = *nextKey++;
			[itemDict setObject:item forKey:[NSNumber numberWithInt:keyEquiv]];

			NSRect rect = NSMakeRect(itemIndent, yPos, viewRect.size.width, 10 );
			NSButton * button = [[NSButton alloc] initWithFrame:rect];	
			[button setButtonType:how == PICK_ANY ? NSSwitchButton 
								 : how == PICK_ONE ? NSRadioButton
								 : NSMomentaryChangeButton];
			[button setBordered:NO];
			[button setTag:keyEquiv];
			[button setKeyEquivalent:[NSString stringWithFormat:@"%c", keyEquiv]];
			[button setTarget:self];
			[button setAction:@selector(buttonClick:)];

			NSString * title = [item title];
			NSString * detail = [item detail];
			if ( detail ) {
				title = [NSString stringWithFormat:@"  %@ (%@)", title, detail];
			} else {
				title = [NSString stringWithFormat:@"  %@", title];				
			}

			NSMutableAttributedString * aString;
			
			// get image
			int glyph = [item glyph];
			if ( glyph == 5584 )
				glyph = 0;
			if ( glyph ) {
				// get glyph image
				NSImage * image = [[TileSet instance] imageForGlyph:glyph enabled:YES];
				
				// create attributed string with glyph
				NSTextAttachment * attachment = [[NSTextAttachment alloc] init];
				[(NSCell *)[attachment attachmentCell] setImage:image];
				aString = [[NSAttributedString attributedStringWithAttachment:attachment] mutableCopy];
				[attachment release];
			} else {
				NSAttributedString * s = [[NSAttributedString alloc] initWithString:@" "];
				aString = [s mutableCopy];
				[s release];
			}
			
			// add title to string and adjust vertical baseline of text so it aligns with icon
			[[aString mutableString] appendString:title];
			if ( glyph )
				[aString addAttribute:NSBaselineOffsetAttributeName value:[NSNumber numberWithDouble:12.0] range:NSMakeRange(1, [title length])];

			// add identifier
			NSString * identString = [NSString stringWithFormat:@" (%c) ",keyEquiv];

			// icon/key/description
			[[aString mutableString] insertString:identString atIndex:1];
			if ( glyph )
				[aString addAttribute:NSBaselineOffsetAttributeName value:[NSNumber numberWithDouble:12.0] range:NSMakeRange(1, [identString length])];
			
			// set button title
			[button setAttributedTitle:aString];
			
			[aString release];

			if ( [item selected] ) {
				[button setState:NSOnState];
			}
#if 0
			int maxAmt = [item maxAmount];
#endif
			[button sizeToFit];
			[menuView addSubview:button];

			yPos += [button bounds].size.height + 3;
			
			[button release];
		}
	}
	
	if ( how == PICK_NONE ) {
		[acceptButton setEnabled:YES];
		[cancelButton setHidden:YES];
	} else {
		[acceptButton setEnabled:NO];
		[cancelButton setHidden:NO];
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
	viewRect.size.width  = width;
	[menuView setFrame:viewRect];
	[menuView scrollPoint:NSMakePoint(0,0)];
	[menuView setNeedsDisplay:YES];	

	// size containing window
	NSRect rc = [[self window] frame];
	rc.size.height += viewRect.size.height - viewSizeOrig.height;
	rc.size.width  += viewRect.size.width  - viewSizeOrig.width;
	if ( rc.size.height < minimumSize.height )
		rc.size.height = minimumSize.height;
	if ( rc.size.width < minimumSize.width )
		rc.size.width = minimumSize.width;
	
	[[self window] setFrame:rc display:YES];
}

+ (void)menuWindowWithMenu:(NhMenuWindow *)menu
{
	MenuWindowController * win = [[MenuWindowController alloc] initWithMenu:menu];
	[win showWindow:win];
	[win->menuView scrollPoint:NSMakePoint(0,0)];

	if ( [win->menuParams how] == PICK_NONE ) {
		// we can run detached
	} else {
		// need to run modal
		[[NSApplication sharedApplication] runModalForWindow:[win window]];
	}
	
}

@end
