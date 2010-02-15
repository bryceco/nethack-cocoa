//
//  MainView.m
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

#import "MainView.h"
#import "NhWindow.h"
#import "NhMapWindow.h"
#import "TileSet.h"
#import "NhEventQueue.h"

@implementation MainView

- (id)initWithFrame:(NSRect)frame {
	if (self = [super initWithFrame:frame]) {
		tileSize = CGSizeMake(32.0f, 32.0f);
		NSImage *tilesetImage = [NSImage imageNamed:@"chozo32b.png"];
		TileSet *tileSet = [[TileSet alloc] initWithImage:tilesetImage tileSize:NSMakeSize(32.0f, 32.0f)];
		[TileSet setInstance:tileSet];
		petMark = [NSImage imageNamed:@"petmark.png"];
	}
	return self;
}

- (void)refreshMessages {
	NSString *text = [[NhWindow messageWindow] text];
	if (text && text.length > 0) {
	}
	if ([NhWindow statusWindow]) {
		text = [[NhWindow statusWindow] text];
		if (text && text.length > 0) {
		}
	}
}

- (void)cliparoundX:(int)x y:(int)y {
	clipX = x;
	clipY = y;
}

- (void)drawRect:(NSRect)rect {
	NhMapWindow *map = (NhMapWindow *) [NhWindow mapWindow];
	if (map) {
		// since this coordinate system is right-handed, each tile starts above left
		// and draws the area below to the right, so we have to be one tile height off
		NSPoint start = NSMakePoint(0.0f,
									self.bounds.size.height-tileSize.height);
		
		for (int j = 0; j < ROWNO; ++j) {
			for (int i = 0; i < COLNO; ++i) {
				NSPoint p = NSMakePoint(start.x+i*tileSize.width,
										start.y-j*tileSize.height);
				NSRect r = NSMakeRect(p.x, p.y, tileSize.width, tileSize.height);
				if (NSIntersectsRect(r, rect)) {
					int ochar, ocolor;
					unsigned int special;
					int glyph = [map glyphAtX:i y:j];
					if (glyph) {
						mapglyph(glyph, &ochar, &ocolor, &special, i, j);
						NSRect srcRect = [[TileSet instance] sourceRectForGlyph:glyph];
						[[[TileSet instance] image] drawInRect:r fromRect:srcRect operation:NSCompositeCopy fraction:1.0f];
						if (glyph_is_pet(glyph)) {
							[petMark drawInRect:r fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0f];
						}
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

- (void)keyDown:(NSEvent *)theEvent {
	[self interpretKeyEvents:[NSArray arrayWithObject:theEvent]];
}

- (void)insertText:(id)aString {
	//NSLog(@"keys %@", aString);
	const char *pStr = [(NSString *) aString cStringUsingEncoding:NSASCIIStringEncoding];
	[[NhEventQueue instance] addKeys:pStr];
}

@end
