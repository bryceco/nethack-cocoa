//
//  MainView.m
//  NetHack
//
//  Created by dirk on 2/1/10.
//  Copyright 2010 Dirk Zimmermann. All rights reserved.
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

#import "MainView.h"
#import "NhWindow.h"
#import "NhMapWindow.h"
#import "TileSet.h"
#import "NhEventQueue.h"
#import "NhTextInputEvent.h"
#import "NhEvent.h"
#import "wincocoa.h"
#import "TooltipWindow.h"
#import "NSImage+FlippedDrawing.h"
#import "NetHackCocoaAppDelegate.h"

#import "Inventory.h"
#import "NSString+Z.h"

#import <Carbon/Carbon.h>	// key codes


@implementation MainView

@synthesize contextMenu;
@synthesize contextMenuObject;

NSStringEncoding	codepage437encoding;


-(BOOL)isFlipped
{
	return YES;
}

-(void)enableAsciiMode:(BOOL)enable
{
	iflags.wc_ascii_map = enable;
	
	if ( iflags.wc_ascii_map ) {

		// compute required size for selected font
		NSSize total = { 0, 0 };
		NSCell * cell = [[NSCell alloc] initTextCell:@""];
		[cell setFont:asciiFont];
		[cell setEditable:NO];
		[cell setSelectable:NO];
		for ( int ch = 32; ch < 127; ++ch ) {
			NSString * text = [[NSString alloc] initWithFormat:@"%c", ch];
			[cell setTitle:text];

			NSSize size = [cell cellSize];
			
			if ( size.width > total.width )
				total.width = size.width;
			if ( size.height > total.height )
				total.height = size.height;

		}

		tileSize.width = total.width;
		tileSize.height = total.height;
		
	} else {

		tileSize = [TileSet instance].tileSize;

	}

	// update our bounds
	NSRect frame = [self frame];
	frame.size = NSMakeSize( COLNO*tileSize.width, ROWNO*tileSize.height );
	[self setFrame:frame];
	
	[self setNeedsDisplay:YES];
}

-(BOOL)setAsciiFont:(NSFont *)font
{
	asciiFont = font;
	return YES;
}

- (NSFont *)asciiFont
{
	return asciiFont;
}

- (id)initWithFrame:(NSRect)frame {

	if (self = [super initWithFrame:frame]) {
		
		codepage437encoding = CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingDOSLatinUS );

		petMark = [NSImage imageNamed:@"petmark.png"];
		
		// we need to know when we scroll
		NSClipView * clipView = [[self enclosingScrollView] contentView];
		[clipView setPostsBoundsChangedNotifications: YES];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollClipviewBoundsDidChangeNotification:) 
											name:NSViewBoundsDidChangeNotification object:clipView];

		// we need to know when we resize so we can re-center on hero
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(boundsDidChangeNotification:) 
													 name:NSViewFrameDidChangeNotification object:self];
		
		asciiColors = @[
			/* CLR_BLACK			*/	[NSColor colorWithDeviceRed:0.333 green:0.333 blue:0.333 alpha:1.0],
			/* CLR_RED				*/	[NSColor redColor],
			/* CLR_GREEN			*/	[NSColor colorWithDeviceRed:0.0 green:0.5 blue:0.0 alpha:1.0],
			/* CLR_BROWN			*/	[NSColor colorWithDeviceRed:0.666 green:0.166 blue:0.166 alpha:1.0],
			/* CLR_BLUE				*/	[NSColor blueColor],
			/* CLR_MAGENTA			*/	[NSColor magentaColor],
			/* CLR_CYAN				*/	[NSColor cyanColor],
			/* CLR_GRAY				*/	[NSColor colorWithDeviceWhite:0.75 alpha:1.0],
			/* NO_COLOR				*/	[NSColor whiteColor],	// rogue level
			/* CLR_ORANGE			*/	[NSColor colorWithDeviceRed:1.0 green:0.666 blue:0.0 alpha:1.0],
			/* CLR_BRIGHT_GREEN		*/	[NSColor greenColor],
			/* CLR_YELLOW			*/	[NSColor yellowColor],
			/* CLR_BRIGHT_BLUE		*/	[NSColor colorWithDeviceRed:0.0 green:0.75 blue:1.0 alpha:1.0],
			/* CLR_BRIGHT_MAGENTA	*/	[NSColor colorWithDeviceRed:1.0 green:0.50 blue:1.0 alpha:1.0],
			/* CLR_BRIGHT_CYAN		*/	[NSColor colorWithDeviceRed:0.5 green:1.00 blue:1.0 alpha:1.0],
			/* CLR_WHITE			*/	[NSColor whiteColor],
		];
		asciiFont = [NSFont boldSystemFontOfSize:24.0];
	}
		
	return self;
}

- (void)cliparoundX:(int)x y:(int)y
{
	// if we're too close to edge of window then scroll us back
	NSSize border = NSMakeSize(8*tileSize.width, 8*tileSize.height);
	NSSize frame = [[self enclosingScrollView] frame].size;
	if ( border.width > frame.width*0.4 )
		border.width = frame.width*0.4;
	if ( border.height > frame.height*0.4 )
		border.height = frame.height*0.4;
	NSPoint center = NSMakePoint( (x+0.5)*tileSize.width, (y+0.5)*tileSize.height );
	NSRect rect = NSMakeRect( center.x-border.width, center.y-border.height, 2*border.width, 2*border.height );
	[self scrollRectToVisible:rect];	 	 
}
- (void)cliparoundHero
{
	[self cliparoundX:u.ux y:u.uy];
}


- (void)drawRect:(NSRect)rect 
{
	NhMapWindow *map = (NhMapWindow *) [NhWindow mapWindow];
	if (map) {
		NSImage	*	image = [[TileSet instance] image];
		
		// cursor can update asynchronously behind us so gets its location upfront
		XCHAR_P	cursorX, cursorY;
		[map cursX:&cursorX	y:&cursorY];
		
		
		if ( Is_rogue_level(&u.uz) && !iflags.wc_ascii_map ) {
			// FIXME: we draw with the graphical tile dimensions instead of character dimensions in this case
		}
	
		// set stuff up for ascii drawing
		NSMutableAttributedString * aString = [[NSMutableAttributedString alloc] initWithString:@"X"];
		NSRange rangeAll = NSMakeRange(0,[aString length]);
		[aString setAlignment:NSTextAlignmentCenter range:rangeAll];
		[aString addAttribute:NSFontAttributeName value:asciiFont range:rangeAll];
		
		for (int j = 0; j < ROWNO; ++j) {
			for (int i = 0; i < COLNO; ++i) {
				NSRect r = NSMakeRect( i*tileSize.width, j*tileSize.height, tileSize.width, tileSize.height);
				if (NSIntersectsRect(r, rect)) {
					int glyph = [map glyphAtX:i y:j];
					if (glyph != kNoGlyph) {
						
						if ( iflags.wc_ascii_map || Is_rogue_level(&u.uz) ) {
							
							// use ASCII text
							int ochar, ocolor;
							unsigned int special;
							mapglyph(glyph, &ochar, &ocolor, &special, i, j, MG_FLAG_NORMAL);
							
							if ( ochar == 0x1 ) {
								// smiley face in rogue level when using IBMgraphics
								[[aString mutableString] setString:@"☺"];
							} else {
								// use CP437 which correctly maps when using ibm_graphics
								char ch[] = { ochar, 0 };
								NSString * string = [[NSString alloc] initWithCString:ch encoding:codepage437encoding];
								[[aString mutableString] setString:string];
							}
							
							// text color
							NSColor * color = [asciiColors objectAtIndex:ocolor];
							[aString addAttribute:NSForegroundColorAttributeName value:color range:rangeAll];
		
							// background is black
							[[NSColor blackColor] setFill];
							[NSBezierPath fillRect:r];
							
							// draw glyph
							[aString drawInRect:r];
							
						} else {
							
							// draw tile
							NSRect srcRect = [[TileSet instance] sourceRectForGlyph:glyph];
#if __MAC_OS_X_VERSION_MIN_REQUIRED < 1060
							[image drawAdjustedInRect:r fromRect:srcRect operation:NSCompositeCopy fraction:1.0];
#else
							[image drawInRect:r fromRect:srcRect operation:NSCompositingOperationCopy fraction:1.0f respectFlipped:YES hints:nil];
#endif
						}
						
						if (glyph_is_pet(glyph)) {
#if __MAC_OS_X_VERSION_MIN_REQUIRED < 1060
							[petMark drawAdjustedInRect:r fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
#else
							[petMark drawInRect:r fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1.0f respectFlipped:YES hints:nil];
#endif
						}
						
					} else {
						// no glyph at this location
						[[NSColor blackColor] setFill];
						[NSBezierPath fillRect:r];
					}
				}
			}
		}

		// draw cursor rectangle
		NSRect r = NSMakeRect( cursorX*tileSize.width, cursorY*tileSize.height, tileSize.width, tileSize.height);
		// hp100 calculation from qt_win.cpp
		int hp100;
		if (u.mtimedone) {
			hp100 = u.mhmax ? u.mh*100/u.mhmax : 100;
		} else {
			hp100 = u.uhpmax ? u.uhp*100/u.uhpmax : 100;
		}
		
		NSColor * color;
		if (hp100 > 75) {
			color = [NSColor colorWithDeviceRed:0.0 green:0.8 blue:0.0 alpha:0.9];
		} else if (hp100 > 50) {
			color = [NSColor colorWithDeviceRed:0.8 green:0.8 blue:0.0 alpha:0.9];
		} else {
			color = [NSColor colorWithDeviceRed:0.8 green:0.0 blue:0.0 alpha:0.9];
		}
		[color setStroke];
		[NSBezierPath strokeRect:r];
	}
}

#pragma mark NSResponder

- (BOOL)acceptsFirstResponder {
	return YES;
}
- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
	return YES;
}


- (void)mouseDown:(NSEvent *)theEvent
{
	NSPoint mouseLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	mouseLoc.x = (int)(mouseLoc.x / tileSize.width);
	mouseLoc.y = (int)(mouseLoc.y / tileSize.height);
	mouseLoc.y = mouseLoc.y;
	
	NhEvent * e = [NhEvent eventWithX:mouseLoc.x y:mouseLoc.y];
	[[NhEventQueue instance] addEvent:e];
}


#pragma mark Context menu

- (IBAction)showContextInfo:(id)sender
{
}

- (NSString *)cleanTileDescription:(NSString *)text
{
	// remove context string
	NSRange r = [text rangeOfString:@"["];
	if ( r.location != NSNotFound ) {
		text = [text substringToIndex:r.location];
	}
	// remove extra words
	NSArray * a = [NSArray arrayWithObjects:@"tame", @"invisible", @"peaceful", @"a", @"an", @"the", nil];
	for ( NSString * s in a ) {
		r = [text rangeOfString:s withDelimiter:@" "];
		if ( r.location != NSNotFound ) {
			text = [text stringByReplacingCharactersInRange:r withString:@""];
		}
	}
	text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	return text;
}
- (IBAction)doWebSearch:(id)sender
{
	NSString * text = [contextMenuObject stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
	NSString * path = [NSString stringWithFormat:@"http://nethackwiki.com/mediawiki/index.php?search=%@",text];
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:path]];
}

- (NSMenu *) menuForEvent:(NSEvent *)theEvent
{
	NSPoint contextMenuPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	contextMenuPoint.x = (int)(contextMenuPoint.x / tileSize.width);
	contextMenuPoint.y = (int)(contextMenuPoint.y / tileSize.height);
	if ( contextMenuPoint.x >= 0 && contextMenuPoint.x < COLNO && contextMenuPoint.y >= 0 && contextMenuPoint.y < ROWNO ) {
		NSString * text = DescriptionForTile( contextMenuPoint.x, contextMenuPoint.y );
		contextMenuObject = [self cleanTileDescription:text];
		NSMenuItem * item = [contextMenu itemAtIndex:0];
		NSString * title = [NSString stringWithFormat:@"Search the Nethack Wiki for '%@'", contextMenuObject];
		[item setTitle:title];
		return contextMenu;
	}
	return nil;
}

#pragma mark Tooltip

- (void)cancelTooltip
{
	if ( tooltipTimer ) {
		[tooltipTimer invalidate];
		tooltipTimer = nil;
	}
	if ( tooltipWindow ) {
		[tooltipWindow close];	// automatically released when closed
		tooltipWindow = nil;
	}
}


NSString * DescriptionForTile( int x, int y )
{
	char    out_str[BUFSZ];

	// get tile info, but don't interfere with nethack thread
	NetHackCocoaAppDelegate * appDelegate = [[NSApplication sharedApplication] delegate];
	[appDelegate lockNethackCore];
	InventoryOfTile(x, y, out_str);
	[appDelegate unlockNethackCore];

	NSString * text = [NSString stringWithCString:out_str encoding:codepage437encoding];
	
	NSScanner * scanner = [NSScanner scannerWithString:text];
	[scanner setScanLocation:1];
	[scanner setCharactersToBeSkipped:nil];
	if ( [scanner scanString:@"      " intoString:NULL] ) {
		// skipped leading character
	} else {
		[scanner setScanLocation:0];
	}
	// scan to opening paren, if any
	int pos = [scanner scanLocation];
	if ( [scanner scanUpToString:@"(" intoString:NULL] && [scanner isAtEnd] ) {
		// no paren, so take the rest of the string
		return [[scanner string] substringFromIndex:pos];		
	}
	// look for additional opening paren
	do {
		[scanner scanString:@"(" intoString:NULL];
		pos = [scanner scanLocation];
	} while ( [scanner scanUpToString:@"(" intoString:NULL] && ![scanner isAtEnd] );
	[scanner setScanLocation:pos];
	// remove paren and matching closing paren
	[scanner scanUpToString:@")" intoString:&text];
	[scanner scanString:@")" intoString:NULL];
	NSString * rest = [[scanner string] substringFromIndex:[scanner scanLocation]];
	text = [text stringByAppendingString:rest];
	return text;
}

- (void)tooltipFired
{
	[self cancelTooltip];
		
	int tileX = (int)(tooltipPoint.x / tileSize.width);
	int tileY = (int)(tooltipPoint.y / tileSize.height);
	
#if 0
	char buf[ 100 ];
	buf[0] = 0;
	const char * feature = dfeature_at( tileX, tileY, buf);	
	if ( feature ) {
		NSString * text = [NSString stringWithUTF8String:feature];
		NSPoint pt = NSMakePoint( tooltipPoint.x + 2, tooltipPoint.y - 2 );
		tooltipWindow = [[TooltipWindow alloc] initWithText:text location:pt];
	}
#else
	NSString * text = DescriptionForTile(tileX, tileY);
	
	if ( text && [text length] ) {
		NSPoint pt = tooltipPoint;
		
		NSCursor * cursor = [NSCursor currentCursor];
		NSSize size = [[cursor image] size];
		NSPoint hot = [cursor hotSpot];
		pt.x += 2;
		pt.y += size.height - hot.y;
		pt.y += 20; // height of tooltip

		pt = [self convertPoint:pt toView:nil];	// convert view coordinates to window
		pt = [[self window] convertPointToScreen:pt];
		tooltipWindow = [[TooltipWindow alloc] initWithText:text location:pt];
	}
#endif
}

- (void) scrollClipviewBoundsDidChangeNotification:(NSNotification *)notification
{
	[self cancelTooltip];
}
- (void)mouseMoved:(NSEvent *)theEvent
{
	[self cancelTooltip];
	
	tooltipPoint = [theEvent locationInWindow];	// window coordinates
	tooltipPoint = [self convertPoint:tooltipPoint fromView:nil];	// convert to view coordinates

	NSRect visrect = [self visibleRect];
	if ( !NSPointInRect( tooltipPoint, visrect ) )
		return;
		
	tooltipTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(tooltipFired) userInfo:nil repeats:NO];
}

- (void) boundsDidChangeNotification:(NSNotification *)notification
{
	// not sure if we can do this synchronously...
	[self performSelector:@selector(cliparoundHero) withObject:nil afterDelay:0.0];
}


static NSEvent * g_pendingKeyEvent = nil;

- (void)keyDown:(NSEvent *)theEvent
{
	if ( [theEvent type] == NSEventTypeKeyDown ) {

		if ( g_pendingKeyEvent ) {
			unsigned short k1 = [g_pendingKeyEvent keyCode];
			unsigned short k2 = [theEvent keyCode];
			unsigned int newKeyCode = 0;
			if ( (k1 == kVK_LeftArrow && k2 == kVK_UpArrow) || (k2 == kVK_LeftArrow && k1 == kVK_UpArrow) )	{
				newKeyCode = kVK_ANSI_Keypad7;
			} else if ( (k1 == kVK_RightArrow && k2 == kVK_UpArrow) || (k2 == kVK_RightArrow && k1 == kVK_UpArrow) ) {
				newKeyCode = kVK_ANSI_Keypad9;
			} else if ( (k1 == kVK_LeftArrow && k2 == kVK_DownArrow) || (k2 == kVK_LeftArrow && k1 == kVK_DownArrow) )	{
				newKeyCode = kVK_ANSI_Keypad1;
			} else if ( (k1 == kVK_RightArrow && k2 == kVK_DownArrow) || (k2 == kVK_RightArrow && k1 == kVK_DownArrow) ) {
				newKeyCode = kVK_ANSI_Keypad3;
			} else {
				wchar_t key = [WinCocoa keyWithKeyEvent:g_pendingKeyEvent];
				if ( key ) {
					[[NhEventQueue instance] addKey:key];
				}
			}
			g_pendingKeyEvent = nil;
			if ( newKeyCode ) {
				NSEvent * newEvent = [NSEvent keyEventWithType:NSEventTypeKeyDown
													  location:theEvent.locationInWindow
												 modifierFlags:theEvent.modifierFlags
													 timestamp:theEvent.timestamp
												  windowNumber:theEvent.windowNumber
													   context:nil
													characters:@""
								   charactersIgnoringModifiers:@""
													 isARepeat:theEvent.isARepeat
													   keyCode:newKeyCode];
				theEvent = newEvent;
			}
		} else {
			switch ( [theEvent keyCode] ) {
				case kVK_LeftArrow:
				case kVK_RightArrow:
				case kVK_DownArrow:
				case kVK_UpArrow:
					g_pendingKeyEvent = theEvent;
					return;
			}
		}

		wchar_t key = [WinCocoa keyWithKeyEvent:theEvent];
		if ( key ) {
			[[NhEventQueue instance] addKey:key];
		}
	}
}

- (void)keyUp:(NSEvent *)theEvent
{
	if ( [theEvent type] == NSEventTypeKeyUp ) {
		if ( g_pendingKeyEvent ) {
			wchar_t key = [WinCocoa keyWithKeyEvent:g_pendingKeyEvent];
			if ( key ) {
				[[NhEventQueue instance] addKey:key];
			}
		}
		g_pendingKeyEvent = nil;
	}
}

@end
