//
//  MainViewController.m
//  NetHack
//
//  Created by dirk on 2/1/10.
//  Copyright 2010 Dirk Zimmermann. All rights reserved.
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

#import "MainWindowController.h"
#import "MainView.h"
#import "NhYnQuestion.h"
#import "NSString+Z.h"
#import "NhEventQueue.h"
#import "NhWindow.h"
#import "NhMenuWindow.h"
#import "MainView.h"
#import "NhEvent.h"
#import "NhTextInputEvent.h"
#import "NhCommand.h"
#import "MenuWindowController.h"
#import "MessageWindowController.h"
#import "DirectionWindowController.h"
#import "YesNoWindowController.h"
#import "InputWindowController.h"
#import "ExtCommandWindowController.h"
#import "PlayerSelectionWindowController.h"
#import "StatsView.h"

#import "wincocoa.h" // cocoa_getpos etc.

#include "hack.h" // BUFSZ etc.

static MainWindowController* instance;
static const float popoverItemHeight = 44.0f;

@implementation MainWindowController

+ (MainWindowController *)instance {
	return instance;
}

// Convert keyEquivs in menu items to use their shifted equivalent
// This makes them display with their more conventional character
// bindings and lets us work internationally.
- (void)fixMenuKeyEquivalents:(NSMenu *)menu
{
	for ( NSMenuItem * item in [menu itemArray] ) {
		if ( [item hasSubmenu] ) {
			NSMenu * submenu = [item submenu];
			[self fixMenuKeyEquivalents:submenu];
		} else {
			NSUInteger mask = [item keyEquivalentModifierMask];
			if ( mask & NSShiftKeyMask ) {
				NSString * key = [item keyEquivalent];
				switch ( [key characterAtIndex:0] ) {
					case '1':		key = @"!";		break;
					case '2':		key = @"@";		break;
					case '3':		key = @"#";		break;
					case '4':		key = @"$";		break;
					case '5':		key = @"%";		break;
					case '6':		key = @"^";		break;
					case '7':		key = @"&";		break;
					case '8':		key = @"*";		break;
					case '9':		key = @"(";		break;
					case '0':		key = @")";		break;
					case '.':		key = @">";		break;
					case ',':		key = @"<";		break;
					case '/':		key = @"?";		break;
					case '[':		key = @"{";		break;
					case ']':		key = @"}";		break;
					case ';':		key = @":";		break;
					case '\'':		key = @"\"";	break;
					case '-':		key = @"_";		break;
					case '=':		key = @"+";		break;
					default:		key = nil;		break;
				}
				if ( key ) {
					mask &= ~NSShiftKeyMask;
					[item setKeyEquivalent:key];
					[item setKeyEquivalentModifierMask:mask];
				}				
			}
		}
	}
}

- (void)awakeFromNib {
	[super awakeFromNib];
	instance = self;
	
	NSMenu * menu = [[NSApplication sharedApplication] mainMenu];
	[self fixMenuKeyEquivalents:menu];
	
	[[self window] setAcceptsMouseMovedEvents:YES];
}

#pragma mark menu actions

-(BOOL)windowShouldClose:(id)sender
{
	return NO;
}
-(void)performClose:(id)sender
{
}

- (void)performMenuAction:(id)sender
{
	NSMenuItem * menuItem = sender;
	NSString * key = [menuItem keyEquivalent];
	if ( key && [key length] ) {
		// it has a key equivalent to use
		char keyEquiv = [key characterAtIndex:0];
		int modifier = [menuItem keyEquivalentModifierMask];
		if ( modifier & NSControlKeyMask ) {
			keyEquiv = toupper(keyEquiv) - 'A' + 1;
		}
		if ( modifier & NSAlternateKeyMask ) {
			keyEquiv = 0x80 | keyEquiv;
		}
		[[NhEventQueue instance] addKey:keyEquiv];
	} else {
		// maybe an extended command?
		NSString * cmd = [menuItem title];
		if ( [cmd characterAtIndex:0] == '#' ) {
			cmd = [cmd substringFromIndex:1];
			cmd = [cmd lowercaseString];
			NhTextInputEvent * e = [NhTextInputEvent eventWithText:cmd];
			[[NhEventQueue instance] addKey:'#'];
			[[NhEventQueue instance] addEvent:e];
		} else {
			// unknown
			NSAlert * alert = [NSAlert alertWithMessageText:@"Menu binding not implemented" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
			[alert runModal];		
		}
	}
}
- (void)addTileSet:(id)sender
{
	NSOpenPanel * panel = [NSOpenPanel openPanel];
	[panel setCanChooseFiles:YES];
	[panel setCanChooseDirectories:NO];
	[panel setAllowsMultipleSelection:YES];
	[panel runModal];
	NSArray * result = [panel URLs];
	for ( NSURL * url in result ) {
		NSString * s = [url absoluteString];
		NSMenuItem * item = [[NSMenuItem alloc] initWithTitle:s action:@selector(selectTileSet:) keyEquivalent:@""];
		[item setTarget:self];
		[tileSetMenu addItem:item];
		[item release];
	}
}
- (void)selectTileSet:(id)sender
{
	NSMenuItem * item = sender;
	NSString * name = [item title];
	int dx, dy;
	if ( sscanf([name UTF8String], "%*[^0-9]%dx%d.%*s", &dx, &dy ) == 2 ) {
		// fully described
	} else if ( sscanf([name UTF8String], "%*[^0-9]%d.%*s", &dx ) == 1 ) {
		dy = dx;
	} else {
		dx = dy = 16;
	}
	
	NSSize size = NSMakeSize( dx, dy );
	BOOL ok = [mainView setTileSet:name size:size];
	if ( ok ) {
		// ok
	} else {
		NSAlert * alert = [NSAlert alertWithMessageText:@"The tile set could not be loaded" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@"The file may be unreadable, or the dimensions may not be appropriate"];
		[alert runModal];
	}
}
- (void)createTileSetListInMenu:(NSMenu *)menu {
	int count = [[menu itemArray] count];
	if ( count > 3 ) {
		// already initialized
		return;
	}

	NSMutableArray * files = [NSMutableArray array];
	// add user defined tile file
	if (iflags.wc_tile_file) {
		[files addObject:[NSString stringWithUTF8String:iflags.wc_tile_file]];
	}	
	
	// get list of builtin tiles
	NSString * tileFolder = [[NSBundle mainBundle] resourcePath];
	for ( NSString * name in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:tileFolder error:NULL] ) {
		NSString * ext = [name pathExtension];
		if ( [ext isEqualToString:@"png"] || [ext isEqualToString:@"bmp"] ) {
			// we have an image file, just make sure it is larger than a single image (petmark)
			NSString * path = [tileFolder stringByAppendingPathComponent:name];
			NSDictionary * attr = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:NULL];
			if ( attr && [attr fileSize] >= 10000 ) {
				[files addObject:name];
			}				
		}
	}
	
	// add files
	for ( NSString * name in files ) {
		NSMenuItem * item = [[NSMenuItem alloc] initWithTitle:name action:@selector(selectTileSet:) keyEquivalent:@""];
		[item setTarget:self];
		[menu addItem:item];
		[item release];
	}
}
- (void)menuWillOpen:(NSMenu *)menu
{
	if ( menu == tileSetMenu ) {
		[self createTileSetListInMenu:menu];
	}
}


- (IBAction)terminateApplication:(id)sender
{
	// map to Cmd-Q to Shift-S
	[[NhEventQueue instance] addKey:'S'];	
}

#pragma mark window API

- (void)refreshMessages {
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(refreshMessages) withObject:nil waitUntilDone:NO];
	} else {
		NSAttributedString *attrText = [[NhWindow messageWindow] attributedText];
		if (attrText && attrText.length > 0) {
			[messagesView setEditable:YES];
			[messagesView setString:@""];
			[messagesView insertText:attrText];
			[messagesView scrollRangeToVisible: NSMakeRange([[messagesView string] length], 0)];
			[messagesView setEditable:NO];
		}
		NSString * text = [[NhWindow statusWindow] text];
		if (text && text.length > 0) {
			[statusView setStringValue:text];
		}
		for ( NSString * text in [[NhWindow statusWindow] messages] ) {
			[statsView setItems:text];
		}
	}
}


- (void)showExtendedCommands
{
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(showExtendedCommands) withObject:nil waitUntilDone:NO];
	} else {
		[extCommandWindow runModal];
	}
}

- (void)showPlayerSelection
{
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(showPlayerSelection) withObject:nil waitUntilDone:YES];
	} else {
		[showPlayerSelection runModal];
	}	
}

- (void)handleDirectionQuestion:(NhYnQuestion *)q {
	isDirectionQuestion = YES;
	[directionWindow runModalWithPrompt:q.question];
}

// Parses the stuff in [] and returns the special characters like $-?* etc.
// examples:
// [$abcdf or ?*]
// [a or ?*]
// [- ab or ?*]
// [- or or ?*]
// [- a or ?*]
// [- a-cw-z or ?*]
// [- a-cW-Z or ?*]
- (void)parseYnChoices:(NSString *)lets specials:(NSString **)specials items:(NSString **)items {
	char cSpecials[BUFSZ];
	char cItems[BUFSZ];
	char *pSpecials = cSpecials;
	char *pItems = cItems;
	const char *pStr = [lets cStringUsingEncoding:NSASCIIStringEncoding];
	enum eState { start, inv, invInterval, end } state = start;
	char c, lastInv = 0;
	while (c = *pStr++) {
		switch (state) {
			case start:
				if (isalpha(c)) {
					state = inv;
					*pItems++ = c;
				} else if (!isalpha(c)) {
					if (c == ' ') {
						state = inv;
					} else {
						*pSpecials++ = c;
					}
				}
				break;
			case inv:
				if (isalpha(c)) {
					*pItems++ = c;
					lastInv = c;
				} else if (c == ' ') {
					state = end;
				} else if (c == '-') {
					state = invInterval;
				}
				break;
			case invInterval:
				if (isalpha(c)) {
					for (char a = lastInv+1; a <= c; ++a) {
						*pItems++ = a;
					}
					state = inv;
					lastInv = 0;
				} else {
					// never lands here
					state = inv;
				}
				break;
			case end:
				if (!isalpha(c) && c != ' ') {
					*pSpecials++ = c;
				}
				break;
			default:
				break;
		}
	}
	*pSpecials = 0;
	*pItems = 0;
	
	*specials = [NSString stringWithCString:cSpecials encoding:NSASCIIStringEncoding];
	*items = [NSString stringWithCString:cItems encoding:NSASCIIStringEncoding];
}

- (void)showDirectionWithPrompt:(NSString *)prompt
{
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(showDirectionWithPrompt:) withObject:prompt waitUntilDone:NO];
	} else {
		[directionWindow runModalWithPrompt:prompt];
	}			
}

- (void)showYnQuestion:(NhYnQuestion *)q {
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(showYnQuestion:) withObject:q waitUntilDone:NO];
	} else {
		if ([q.question containsString:@"direction"]) {
			[self handleDirectionQuestion:q];
		} else if (q.choices) {
			// simple YN question
			// "Which ring finger, Right or Left?" "rl"
			NSString *text = q.question;
			
			if (text && text.length > 0) {
				
				// trip response options from prompt
				NSString * response = [text substringBetweenDelimiters:@"[]"];		
				if ( response ) {
					response = [NSString stringWithFormat:@"[%@]", response];
					text = [text stringByReplacingOccurrencesOfString:response withString:@""];
				}
				
				if ( strcmp( q.choices, "yn" ) == 0 || strcmp( q.choices, "ynq" ) == 0 ) {					
					[yesNoWindow runModalWithQuestion:text choice1:@"Yes" choice2:@"No" canCancel:strlen(q.choices)==3];
				} else if ( strcmp( q.choices, "rl" ) == 0 ) {
					[yesNoWindow runModalWithQuestion:text choice1:@"Right" choice2:@"Left" canCancel:NO];
				} else {
					assert(NO);
				}
			}
		} else {
			// very general question, could be everything
			NSString * args = [q.question substringBetweenDelimiters:@"[]"];		
			NSString * specials = nil;
			NSString * items = nil;
			[self parseYnChoices:args specials:&specials items:&items];
			
			BOOL questionMark = [args containsString:@"?"];
			if (questionMark && [items length] > 1) {
				// ask for a comprehensive list instead
				[[NhEventQueue instance] addKey:'?'];
			} else if ( [items length] == 1 ) {
				// do nothing for only a single arg
			} else {
				NSLog(@"unknown question %@", q.question);
				//assert( NO );
			}
		}
	}
}

- (void)refreshAllViews {
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(refreshAllViews) withObject:nil waitUntilDone:NO];
	} else {
		// hardware keyboard
		[self refreshMessages];
	}
}


- (void)displayMessageWindow:(NSString *)text {
	if ( [text length] == 0 ) {
		// do nothing
	} else if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(displayMessageWindow:) withObject:text waitUntilDone:NO];
	} else {
		[MessageWindowController messageWindowWithText:text];
	}
}

- (void)displayWindow:(NhWindow *)w {
	if (![NSThread isMainThread]) {

		BOOL blocking = w.blocking;
		[self performSelectorOnMainThread:@selector(displayWindow:) withObject:w waitUntilDone:blocking];

	} else {
		
		if (w == [NhWindow messageWindow]) {
			[self refreshMessages];
		} else if (w.type == NHW_MAP) {
			[mainView centerHero];
			[mainView setNeedsDisplay:YES];
		} else if ( w.type == NHW_STATUS ) {
			NSString * text = [w text];
			if ( [text length] ) {
				[statusView setStringValue:text];
			}
			for ( NSString * text in [w messages] ) {
				[statsView setItems:text];
			}
		} else {
			NSString * text = [w text];
			if ( [text length] ) {
				[MessageWindowController messageWindowWithText:text];
			}
		}
	}
}

- (void)showMenuWindow:(NhMenuWindow *)w {
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(showMenuWindow:) withObject:w waitUntilDone:NO];
	} else {
		[MenuWindowController menuWindowWithMenu:w];
	}
}

- (void)clipAround:(NSValue *)clip {
	NSRange r = [clip rangeValue];
	[mainView cliparoundX:r.location y:r.length];
}

- (void)clipAroundX:(int)x y:(int)y {
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(clipAround:)
							   withObject:[NSValue valueWithRange:NSMakeRange(x, y)] waitUntilDone:NO];
	} else {
		[mainView cliparoundX:x y:y];
	}
}

- (void)updateInventory {
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(updateInventory) withObject:nil waitUntilDone:NO];
	} else {
	}
}

- (void)getLine {
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(getLine) withObject:nil waitUntilDone:NO];
	} else {
		NSAttributedString * attrPrompt = [[[NhWindow messageWindow] messages] lastObject];
		NSString * prompt = [attrPrompt string];
		[inputWindow runModalWithPrompt:prompt];
	}
}

#pragma mark touch handling

- (int)keyFromDirection:(e_direction)d {
	static char keys[] = "kulnjbhy\033";
	return keys[d];
}

- (BOOL)isMovementKey:(char)k {
	if (isalpha(k)) {
		static char directionKeys[] = "kulnjbhy";
		char *pStr = directionKeys;
		char c;
		while (c = *pStr++) {
			if (c == k) {
				return YES;
			}
		}
	}
	return NO;
}

- (e_direction)directionFromKey:(char)k {
	switch (k) {
		case 'k':
			return kDirectionUp;
		case 'u':
			return kDirectionUpRight;
		case 'l':
			return kDirectionRight;
		case 'n':
			return kDirectionDownRight;
		case 'j':
			return kDirectionDown;
		case 'b':
			return kDirectionDownLeft;
		case 'h':
			return kDirectionLeft;
		case 'y':
			return kDirectionUpLeft;
	}
	return kDirectionMax;
}

- (void)handleMapTapTileX:(int)x y:(int)y forLocation:(CGPoint)p inView:(NSView *)view {
	//NSLog(@"tap on %d,%d (u %d,%d)", x, y, u.ux, u.uy);
	if (isDirectionQuestion) {
		isDirectionQuestion = NO;
		CGPoint delta = CGPointMake(x*32.0f-u.ux*32.0f, y*32.0f-u.uy*32.0f);
		delta.y *= -1;
		//NSLog(@"delta %3.2f,%3.2f", delta.x, delta.y);
		e_direction direction = [ZDirection directionFromEuclideanPointDelta:&delta];
		int key = [self keyFromDirection:direction];
		//NSLog(@"key %c", key);
		[[NhEventQueue instance] addKey:key];
	} else {
		// travel / movement
		[[NhEventQueue instance] addEvent:[NhEvent eventWithX:x y:y]];
	}
}

// probably not used in cocoa
- (void)handleDirectionTap:(e_direction)direction {
	int key = [self keyFromDirection:direction];
	[[NhEventQueue instance] addKey:key];
}

- (void)handleDirectionDoubleTap:(e_direction)direction {
	if (!cocoa_getpos) {
		int key = [self keyFromDirection:direction];
		[[NhEventQueue instance] addKey:'g'];
		[[NhEventQueue instance] addKey:key];
	}
}

#pragma mark misc

- (void)dealloc {
    [super dealloc];
}

@end
