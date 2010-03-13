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

#define RUN_MODAL	1
#define QUICK_PICK	1


@implementation MenuWindowController


-(void)buttonClick:(id)sender
{
	[acceptButton setEnabled:YES];
	
	switch ( [menuParams how] ) {

		case PICK_NONE:
			break;
			
		case PICK_ONE:
			{
#if QUICK_PICK
				[self doAccept:nil];
#else
				// unselect any other items
				NSButton * button = sender;				
				for ( NSButton * item in [menuView subviews] ) {
					if ( [item class] == [button class]  &&  item != button )  {
						[item setState:NSOffState];
					}
				}
#endif
			}
			break;
	
		case PICK_ANY:
			break;
		
		default:
			break;
	}
}

-(IBAction)selectAll:(id)sender
{
	for ( NSButton * item in [menuView subviews] ) {
		if ( [item class] == [NSButton class] )  {
			[item setState:NSOnState];
		}
	}
	[acceptButton setEnabled:YES];
}

-(IBAction)selectUnknownBUC:(id)sender
{
	for ( NSButton * item in [menuView subviews] ) {
		if ( [item class] == [NSButton class] )  {
			BOOL known = NO;
			NSString * text = [[item attributedTitle] string];
			if ( [text rangeOfString:@"blessed"].location != NSNotFound ||
				 [text rangeOfString:@"cursed"].location != NSNotFound ||
				 [text rangeOfString:@"uncursed"].location != NSNotFound )
			{
				known = YES;
			}
			[item setState:known ? NSOffState : NSOnState];
		}
	}	
	[acceptButton setEnabled:YES];
}


-(void)doAccept:(id)sender
{
	// get list of selected tags
	for ( NSButton * button in [menuView subviews] ) {
		if ( [button class] == [NSButton class]  &&  [button state] == NSOnState )  {
			// add selected item
			NSInteger key = [button tag];
			NhItem * item = [itemDict objectForKey:[NSNumber numberWithInt:key]];
			assert(item);
			[menuParams.selected addObject:item];
		}
	}
	
	switch ( [menuParams how] ) {
		case PICK_NONE:
			break;
		case PICK_ONE:
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
	if ( RUN_MODAL || [menuParams how] != PICK_NONE ) {
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


-(int)leadingSpaces:(NSString *)text
{
	int i = 0;
	while ( i < [text length] && [text characterAtIndex:i] == ' ' )
		++i;
	return i;
}


-(NSString *)stringWithSpacesReplacedByTabs:(NSString *)text
{
	NSMutableString * result = [NSMutableString stringWithString:text];
	for ( int pos = 0; pos+1 < [result length]; ++pos ) {
		if ( [result characterAtIndex:pos] == ' ' && [result characterAtIndex:pos+1] == ' ' ) {
			// string of two or more spaces
			int end = pos+2;
			while ( end < [result length] && [result characterAtIndex:end] == ' ' )
				++end;
			[result replaceCharactersInRange:NSMakeRange(pos, end-pos) withString:@"\t"];

		} else if ( [result characterAtIndex:pos] == ' ' && [result characterAtIndex:pos+1] == '[' ) {
			// space followed by bracketed list
			[result replaceCharactersInRange:NSMakeRange(pos,1) withString:@"\t"];
		}
	}
	return result;
}

-(void)convertFakeGroupsToRealGroups
{
	NhItemGroup		*	currentRealGroup = nil;
	NSMutableArray	*	remove = [NSMutableArray arrayWithCapacity:0];
	int					index = 0;
	
	for ( NhItemGroup * group in [menuParams itemGroups] ) {
		
		// seen in Enhance menu for maxed out skills:
		if ( [group.title hasPrefix:@"   #  "] ) {
			[group setTitle: [NSString stringWithFormat:@"      #%@", [group.title substringFromIndex:6]]];
		}
		if ( [group.title hasPrefix:@"   *  "] ) {
			[group setTitle: [NSString stringWithFormat:@"      *%@", [group.title substringFromIndex:6]]];
		}
		
		int leadingSpaces = [self leadingSpaces:group.title];
		
		if ( leadingSpaces >= 4 && currentRealGroup ) {
			
			// It's not a real group. Convert it to a disabled button under the last real group
			ANY_P ident = { 0 };
			ident.a_int = -1;
			NhItem * item = [[NhItem alloc] initWithTitle:[group.title substringFromIndex:leadingSpaces] identifier:ident accelerator:0 glyph:NO_GLYPH selected:NO];
			[currentRealGroup addItem:item];
			[item release];
			[remove addObject:[NSNumber numberWithInt:index]];
			--index;
			
			// add its items to last real group
			for ( NhItem * item in group.items ) {
				
				// strip leading spaces
				[item setTitle:[item.title substringFromIndex:[self leadingSpaces:item.title]]];

				[currentRealGroup addItem:item];
			}
			
		} else {			

			// add its items to last real group
			for ( NhItem * item in group.items ) {
				// strip leading spaces
				[item setTitle:[item.title substringFromIndex:[self leadingSpaces:item.title]]];
			}
			
			currentRealGroup = group;
		}
		++index;
	}
	
	for ( NSNumber * idx in remove ) {
		index = [idx intValue];
		NSIndexPath * indexPath = [NSIndexPath indexPathWithIndex:index];
		[menuParams removeItemAtIndexPath:indexPath];
	}
}


-(void)convertSpacesToTabs
{
	for ( NhItemGroup * group in [menuParams itemGroups] ) {
		
		NSString * title = [self stringWithSpacesReplacedByTabs:group.title];
		[group setTitle:title];
		
		for ( NhItem * item in [group items] ) {
			
			title = [self stringWithSpacesReplacedByTabs:item.title];
			[item setTitle:title];
		}
	}
}


-(void)log:(NSString *)text
{
	NSMutableString * result = [NSMutableString stringWithCapacity:20];
	for ( int i = 0; i < [text length]; ++i ) {
		char ch = [text characterAtIndex:i];
		switch ( ch ) {
			case ' ':
				[result appendString:@"."];
				break;
			case '\t':
				[result appendString:@"\\t"];
				break;
			default:
				[result appendFormat:@"%c", ch ];
				break;
		}
	}
	NSLog(@"%@\n", result );
}

-(void)expandTitleTextWithKeysAndDescriptions
{
	const char	*	nextKey		= "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";

	for ( NhItemGroup * group in [menuParams itemGroups] ) {
		
		for ( NhItem * item in [group items] ) {			
			
			BOOL isEnabled = item.identifier.a_int != -1;
			int keyEquiv = [item inventoryLetter];			
			if ( keyEquiv == 0 && isEnabled && *nextKey ) {
				keyEquiv = *nextKey++;
				[item setInventoryLetter:keyEquiv];
			}
			
			// get key
			NSString * title = isEnabled ? keyEquiv ? [NSString stringWithFormat:@" (%c)",keyEquiv] : @" ( )" : @"";
			// add title
			title = [title stringByAppendingFormat:@"\t%@", [item title]];
			// add detail
			if ( [item detail] ) {
				title = [title stringByAppendingFormat:@" (%@)", [item detail]];
			}
			
			// save expanded title
			[item setTitle:title];
		}
	}
}



-(void)adjustColumnWidths:(NSMutableArray *)widths forString:(NSString *)text attributes:(NSDictionary *)attributes glyphWidth:(CGFloat)glyphWidth
{
	NSArray * fields = [text componentsSeparatedByString:@"\t"];
	int idx = 0;
	
	for ( NSString * field in fields ) {

		CGFloat width = [field sizeWithAttributes:attributes].width;
		
		if ( idx == 0 )
			width += glyphWidth;
		
		if ( idx >= [widths count] ) {
			[widths addObject:[NSNumber numberWithFloat:width]];
		} else {
			if ( width > [[widths objectAtIndex:idx] floatValue] ) {
				[widths replaceObjectAtIndex:idx withObject:[NSNumber numberWithFloat:width]];
			}
		}
		++idx;
	}
}

- (NSMutableArray *)computeTabStopsWithGroupAttr:(NSDictionary *)groupAttributes itemAttr:(NSDictionary *)itemAttributes
{
	NSMutableArray	*	itemWidths	= [NSMutableArray array];
	NSMutableArray	*	groupWidths	= [NSMutableArray array];

	for ( NhItemGroup * group in [menuParams itemGroups] ) {
		
		// if group has no items or has no tabs then ignore it for purposes of calculating tabs
		if ( [[group items] count] > 0  &&  [group.title rangeOfString:@"\t"].location != NSNotFound ) {
			[self adjustColumnWidths:itemWidths forString:group.title attributes:groupAttributes glyphWidth:0.0];
		} else {
			[self adjustColumnWidths:groupWidths forString:group.title attributes:groupAttributes glyphWidth:0.0];
		}
		
		for ( NhItem * item in [group items] ) {
			CGFloat glyphWidth = 0.0;
			if ( [item glyph] != NO_GLYPH ) {
				glyphWidth = [[TileSet instance] tileSize].width;
			}
			[self adjustColumnWidths:itemWidths forString:item.title attributes:itemAttributes glyphWidth:glyphWidth];
		}
	}
	
	// only use group tabs if we never saw any items
	if ( [itemWidths count] == 0 )
		itemWidths = groupWidths;
	
	// convert widths to tab stops
	NSMutableArray * tabs = [NSMutableArray arrayWithCapacity:[itemWidths count]];
	CGFloat pos = 0.0;
	CGFloat SPACE = 5.0;
	for ( NSNumber * width in itemWidths ) {
		pos += [width floatValue] + SPACE;
		NSTextTab * tab = [[NSTextTab alloc] initWithType:NSLeftTabStopType location:pos];
		[tabs addObject:tab];
		[tab release];	
	}
	
	return tabs;
}




-(void)windowDidLoad
{
	NSSize						minimumSize = [[self window] frame].size;
	NSFont					*	groupFont	= [NSFont labelFontOfSize:15];
	NSMutableDictionary		*	groupAttr	= [NSMutableDictionary dictionaryWithObject:groupFont forKey:NSFontAttributeName];
	NSMutableDictionary		*	itemAttr	= [NSMutableDictionary dictionary];
	int							how			= [menuParams how];
	NSInteger					itemTag		= 0;

	BOOL showShortcuts = how == PICK_ANY 
					&& ([[menuParams itemGroups] count] != 1
						||  ![[[[menuParams itemGroups] objectAtIndex:0] title] isEqualToString:@"All"]);
	
	// add new labels
	CGFloat groupIndent	= 25.0;
	CGFloat itemIndent	= 40.0;
	NSRect  viewRect = [menuView bounds];
		
	// fix up the weirdness associated with #enhance menu
	[self convertFakeGroupsToRealGroups];

	// add key equivalents and expand title text
	[self expandTitleTextWithKeysAndDescriptions];
	
	if ( !iflags.menu_tab_sep ) {
		// convert runs of spaces to tabs, to we can generate tab stops for them
		[self convertSpacesToTabs];
	}
	
	// compute tab stops for items
	NSMutableArray * tabStops = [self computeTabStopsWithGroupAttr:groupAttr itemAttr:itemAttr];

	// add tab stops to group attributes
	NSMutableParagraphStyle *	groupPara	= [[[NSMutableParagraphStyle defaultParagraphStyle] mutableCopyWithZone:nil] autorelease];
	[groupPara setTabStops:tabStops];
	[groupAttr setObject:groupPara forKey:NSParagraphStyleAttributeName];
	
	// add tab stops to item attributes
	NSMutableParagraphStyle *	itemPara	= [[[NSMutableParagraphStyle defaultParagraphStyle] mutableCopyWithZone:nil] autorelease];
	[itemPara setTabStops:tabStops];
	[itemAttr setObject:itemPara forKey:NSParagraphStyleAttributeName];
	
	CGFloat checkboxWidth = 32.0;	// depends on NSButtonCell implementation
	
	// loop through menu items and create labels/button for everything
	CGFloat yPos = 0.0;
	for ( NhItemGroup * group in [menuParams itemGroups] ) {
		
		NSRect rect = NSMakeRect(groupIndent, yPos, viewRect.size.width, 10 );
		if ( [group.title length] > 0 && [group.title characterAtIndex:0] == '\t' ) {
			// group is indented, so compensate for button image size
			rect.origin.x += checkboxWidth;
		}
		
		// create text box for group
		NSTextField * label = [[NSTextField alloc] initWithFrame:rect];
		
		// create title attributed string
		NSString * title = [group title];
		NSAttributedString * aTitle = [[NSAttributedString alloc] initWithString:title attributes:groupAttr];
		[label setObjectValue:aTitle];
		[aTitle release];
		
		[label setEditable:NO];
		[label setDrawsBackground:NO];
		[label setBordered:NO];
		[label setFont:groupFont];
		[label sizeToFit];
		[menuView addSubview:label];
		yPos += [label bounds].size.height;
		[label release];
		
		for ( NhItem * item in [group items] ) {

			// button is disabled if identifier is -1 (which we set zero in convertFakeGroupsToRealGroups)
			BOOL isEnabled = item.identifier.a_int != -1 || how == PICK_NONE;

			NSRect rect = NSMakeRect(itemIndent, yPos, viewRect.size.width, 10 );
			NSButton * button = [[NSButton alloc] initWithFrame:rect];	
			[button setButtonType:how == PICK_ANY ? NSSwitchButton 
								 : how == PICK_ONE ? NSRadioButton
								 : NSMomentaryChangeButton];
			[button setBordered:NO];
			[button setTarget:self];
			[button setAction:@selector(buttonClick:)];
			if ( item.selected ) {
				[button setState:NSOnState];
			}

			// set a unique ID for button to map it to item
			[button setTag:itemTag];
			[itemDict setObject:item forKey:[NSNumber numberWithInt:itemTag]];
			++itemTag;
						
			if ( isEnabled && item.inventoryLetter ) {
				[button setKeyEquivalent:[NSString stringWithFormat:@"%c", item.inventoryLetter]];
			}
			[button setEnabled:isEnabled];

			// create attribute string containing just the image (or space if none)
			NSMutableAttributedString * aString;
			int glyph = [item glyph];
			if ( glyph != NO_GLYPH ) {
				// get glyph image
				NSImage * image = [[TileSet instance] imageForGlyph:glyph enabled:YES];
				
				// create attributed string with glyph
				NSTextAttachment * attachment = [[NSTextAttachment alloc] init];
				[(NSCell *)[attachment attachmentCell] setImage:image];
				aString = [[NSAttributedString attributedStringWithAttachment:attachment] mutableCopy];
				[attachment release];
				
			} else {
				NSAttributedString * s = [[NSAttributedString alloc] initWithString:@""];
				aString = [s mutableCopy];
				[s release];
			}
			
			// get identifier
			NSString * title = [item title];

			// add title to string and adjust vertical baseline of text so it aligns with icon
			[[aString mutableString] appendString:title];
			
			// set paragraph style so we get tabs as we like
			[aString addAttributes:itemAttr range:NSMakeRange(0,[[aString mutableString] length])];

			// adjust baseline of text so it is vertically centered with tile
			if ( glyph != NO_GLYPH ) {
				int offset = ([[TileSet instance] tileSize].height - 8) / 2;
				[aString addAttribute:NSBaselineOffsetAttributeName value:[NSNumber numberWithDouble:offset] range:NSMakeRange(1,[[aString string] length]-1)];
			}
			
			// set button title
			[button setAttributedTitle:aString];
			
			[aString release];

#if 0
			int maxAmt = [item maxAmount];
#endif
			[button sizeToFit];
			[menuView addSubview:button];

			yPos += [button bounds].size.height + 3;
			
			[button release];
		}
	}
	
	if ( !showShortcuts ) {
		[selectAll setHidden:YES];
	}


	if ( how == PICK_NONE ) {
		[acceptButton setTitle:@"Close"];
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
	
	// widen by size of scroll bar in case there is a vertical scrollbar
	rc.size.width += [NSScroller scrollerWidth];
	rc.size.width += 5; // for aesthetics
	
	if ( rc.size.height < minimumSize.height )
		rc.size.height = minimumSize.height;
	if ( rc.size.width < minimumSize.width )
		rc.size.width = minimumSize.width;
	
	[[self window] setFrame:rc display:YES];
}

+ (void)menuWindowWithMenu:(NhMenuWindow *)menu
{
	MenuWindowController * win = [[MenuWindowController alloc] initWithMenu:menu];
	NSString * prompt = [menu prompt];
	if ( prompt ) {
		[[win window] setTitle:prompt];
	}
	[win showWindow:win];
	[win->menuView scrollPoint:NSMakePoint(0,0)];

	if ( !RUN_MODAL && [win->menuParams how] == PICK_NONE ) {
		// we can run detached
	} else {
		// need to run modal
		[[NSApplication sharedApplication] runModalForWindow:[win window]];
	}
	
}

@end
