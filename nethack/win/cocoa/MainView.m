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

#import "Inventory.h"


@implementation MainView

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
		NSCell * cell = [[[NSCell alloc] initTextCell:@""] autorelease];
		[cell setFont:asciiFont];
		[cell setEditable:NO];
		[cell setSelectable:NO];
		for ( int ch = 32; ch < 127; ++ch ) {
			NSString * text = [[NSString alloc] initWithFormat:@"%c", ch];
			[cell setTitle:text];
			[text release];
			
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
	if ( font != asciiFont ) {
		[asciiFont release];
		asciiFont = [font retain];
	}
	return YES;
}

- (NSFont *)asciiFont
{
	return asciiFont;
}

- (NSString *)tileSet
{
	return _tileSetName;
}


-(BOOL)setTileSet:(NSString *)tileSetName size:(NSSize)size
{
	NSImage *tilesetImage = [NSImage imageNamed:tileSetName];
	if ( tilesetImage == nil ) {
		tileSetName = [tileSetName stringByExpandingTildeInPath];
		NSURL * url = [NSURL fileURLWithPath:tileSetName isDirectory:NO];
		tilesetImage = [[[NSImage alloc] initByReferencingURL:url] autorelease];
		if ( tilesetImage == nil ) {
			return NO;
		}
	}
	
	// make sure dimensions work
	NSSize imageSize = [tilesetImage size];
	if ( (imageSize.width / size.width) * (imageSize.height / size.height) < 1014 ) {
		// not enough images
		return NO;
	}
	
	TileSet *tileSet = [[[TileSet alloc] initWithImage:tilesetImage tileSize:size] autorelease];
	[TileSet setInstance:tileSet];
	
	[_tileSetName release];
	_tileSetName = [tileSetName copy];

	return YES;
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
		
		asciiColors = [[NSArray arrayWithObjects:
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
						nil] retain];
		asciiFont = [[NSFont boldSystemFontOfSize:24.0] retain];
	}
		
	return self;
}

- (void)cliparoundX:(int)x y:(int)y {
	// if we're too close to edge of window then scroll us back
	int border = 4;
	NSPoint center = NSMakePoint( (x+0.5)*tileSize.width, (y+0.5)*tileSize.height );
	NSRect rect = NSMakeRect( center.x-tileSize.width*border, center.y-tileSize.height*border, tileSize.width*2*border, tileSize.height*2*border );
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
		NSMutableAttributedString * aString = [[[NSMutableAttributedString alloc] initWithString:@"X"] autorelease];
		NSRange rangeAll = NSMakeRange(0,[aString length]);
		[aString setAlignment:NSCenterTextAlignment range:rangeAll];
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
							mapglyph(glyph, &ochar, &ocolor, &special, i, j);
							
							if ( ochar == 0x1 ) {
								// smiley face in rogue level when using IBMgraphics
								[[aString mutableString] setString:@"☺"];
							} else {
								// use CP437 which correctly maps when using ibm_graphics
								char ch[] = { ochar, 0 };
								NSString * string = [[NSString alloc] initWithCString:ch encoding:codepage437encoding];
								[[aString mutableString] setString:string];
								[string release];								
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
							[image drawInRect:r fromRect:srcRect operation:NSCompositeCopy fraction:1.0f respectFlipped:YES hints:nil];
#endif
						}
						
						if (glyph_is_pet(glyph)) {
#if __MAC_OS_X_VERSION_MIN_REQUIRED < 1060
							[petMark drawAdjustedInRect:r fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
#else
							[petMark drawInRect:r fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f respectFlipped:YES hints:nil];
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

- (void)dealloc {
    [super dealloc];
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

- (void)cancelTooltip
{
	if ( tooltipTimer ) {
		[tooltipTimer invalidate];
		[tooltipTimer release];
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
	InventoryOfTile(x, y, out_str);

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
	NSPoint point = [self convertPoint:tooltipPoint fromView:nil];
	if ( !NSPointInRect( point, [self bounds] ) )
		return;
	
	[self cancelTooltip];
		
	int tileX = (int)(point.x / tileSize.width);
	int tileY = (int)(point.y / tileSize.height);
	
#if 0
	char buf[ 100 ];
	buf[0] = 0;
	const char * feature = dfeature_at( tileX, tileY, buf);	
	if ( feature ) {
		NSString * text = [NSString stringWithUTF8String:feature];
		NSPoint pt = NSMakePoint( tooltipPoint.x + 2, tooltipPoint.y + 2 );
		tooltipWindow = [[TooltipWindow alloc] initWithText:text location:pt];
	}
#else
	NSString * text = DescriptionForTile(tileX, tileY);
	
	if ( text && [text length] ) {
		NSPoint pt = NSMakePoint( point.x + 2, point.y + 2 );
		pt = [self convertPointToBase:pt];
		pt = [[self window] convertBaseToScreen:pt];
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
	
	tooltipPoint = [theEvent locationInWindow];
	tooltipTimer = [[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tooltipFired) userInfo:nil repeats:NO] retain];
}

- (void) boundsDidChangeNotification:(NSNotification *)notification
{
	// not sure if we can do this synchronously...
	[self performSelector:@selector(cliparoundHero) withObject:nil afterDelay:0.0];
}


- (void)keyDown:(NSEvent *)theEvent 
{
	if ( [theEvent type] == NSKeyDown ) {
		
		wchar_t key = [WinCocoa keyWithKeyEvent:theEvent];
		if ( key ) {
			[[NhEventQueue instance] addKey:key];			
		}
	}
}

@end
