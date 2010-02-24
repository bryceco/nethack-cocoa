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

#import "MainView.h"
#import "NhWindow.h"
#import "NhMapWindow.h"
#import "TileSet.h"
#import "NhEventQueue.h"
#import "NhTextInputEvent.h"
#import "NhEvent.h"
#import "wincocoa.h"
#import "TooltipWindow.h"

#import "Inventory.h"


@implementation MainView

-(BOOL)setTileSet:(NSString *)tileSetName size:(NSSize)size
{
	NSImage *tilesetImage = [NSImage imageNamed:tileSetName];
	if ( tilesetImage == nil ) {
		NSURL * url = [NSURL URLWithString:tileSetName];
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
	
	tileSize = size;

	// update our bounds
	NSRect frame = [self frame];
	frame.size = NSMakeSize( COLNO*tileSize.width, ROWNO*tileSize.height );
	[self setFrame:frame];

	TileSet *tileSet = [[[TileSet alloc] initWithImage:tilesetImage tileSize:tileSize] autorelease];
	[TileSet setInstance:tileSet];
	
	[self centerHero];
	[self setNeedsDisplay:YES];
	
	return YES;
}

- (id)initWithFrame:(NSRect)frame {

	if (self = [super initWithFrame:frame]) {
		
		petMark = [NSImage imageNamed:@"petmark.png"];
#if 0
		[self setTileSet:@"absurd128.png" size:NSMakeSize(128,128)];
#else
		[self setTileSet:@"kins32.bmp" size:NSMakeSize(32,32)];
#endif		
		// we need to know when we scroll
		NSClipView * clipView = [[self enclosingScrollView] contentView];
		[clipView setPostsBoundsChangedNotifications: YES];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(boundsDidChangeNotification:) 
											name:NSViewBoundsDidChangeNotification object:clipView];
		
	}
		
	return self;
}

- (void)cliparoundX:(int)x y:(int)y {
	clipX = x;
	clipY = y;
}


// if we're too close to edge of window then scroll us back
- (void)centerHero
{
	int border = 4;
	NSPoint center = NSMakePoint( (u.ux+0.5)*tileSize.width, ((ROWNO-1-u.uy)+0.5)*tileSize.height );
	NSRect rect = NSMakeRect( center.x-tileSize.width*border, center.y-tileSize.height*border, tileSize.width*2*border, tileSize.height*2*border );
	[self scrollRectToVisible:rect];	 	 
}

- (void)drawRect:(NSRect)rect 
{
	[[NSColor blackColor] setFill];
	[NSBezierPath fillRect:rect];
	
	NhMapWindow *map = (NhMapWindow *) [NhWindow mapWindow];
	if (map) {
		// since this coordinate system is right-handed, each tile starts above left
		// and draws the area below to the right, so we have to be one tile height off
		NSPoint start = NSMakePoint(0.0f,
									self.bounds.size.height-tileSize.height);
		
		NSImage * image = [[TileSet instance] image];
		
		for (int j = 0; j < ROWNO; ++j) {
			for (int i = 0; i < COLNO; ++i) {
				NSPoint p = NSMakePoint(start.x+i*tileSize.width,
										start.y-j*tileSize.height);
				NSRect r = NSMakeRect(p.x, p.y, tileSize.width, tileSize.height);
				if (NSIntersectsRect(r, rect)) {
					int glyph = [map glyphAtX:i y:j];
					if (glyph) {
						int ochar, ocolor;
						unsigned int special;
						mapglyph(glyph, &ochar, &ocolor, &special, i, j);
						NSRect srcRect = [[TileSet instance] sourceRectForGlyph:glyph];
						[image drawInRect:r fromRect:srcRect operation:NSCompositeCopy fraction:1.0f];
#if 0
						if (glyph_is_pet(glyph)) {
							[petMark drawInRect:r fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0f];
						}
#endif
					}
				}
			}
		}
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
	mouseLoc.y = ROWNO - 1 - mouseLoc.y;
	
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
	return [NSString stringWithUTF8String:out_str];
}

- (void)tooltipFired
{
	NSPoint point = [self convertPoint:tooltipPoint fromView:nil];
	if ( !NSPointInRect( point, [self bounds] ) )
		return;
	
	[self cancelTooltip];
		
	int tileX = (int)(point.x / tileSize.width);
	int tileY = (int)(point.y / tileSize.height);
	tileY = ROWNO - 1 - tileY;
	
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

- (void) boundsDidChangeNotification:(NSNotification *)notification
{
	[self cancelTooltip];
}
- (void)mouseMoved:(NSEvent *)theEvent
{
	[self cancelTooltip];
	
	tooltipPoint = [theEvent locationInWindow];
	tooltipTimer = [[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tooltipFired) userInfo:nil repeats:NO] retain];
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
