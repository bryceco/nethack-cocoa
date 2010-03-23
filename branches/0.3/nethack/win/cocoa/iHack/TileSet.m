//
//  TileSet.m
//  SlashEM
//
//  Created by dirk on 1/17/10.
//  Copyright 2010 Dirk Zimmermann. All rights reserved.
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

#import "TileSet.h"

static TileSet *s_instance = nil;

@implementation TileSet

@synthesize image;
@synthesize	tileSize;

+ (TileSet *)instance {
	return s_instance;
}

+ (void)setInstance:(TileSet *)ts {
	[s_instance release];
	s_instance = [ts retain];
}

- (id)initWithImage:(NSImage *)img tileSize:(NSSize)ts {
	if (self = [super init]) {
		image = [img retain];
		tileSize = ts;
		rows = image.size.height / tileSize.height;
		columns = image.size.width / tileSize.width;
	}
	return self;
}

- (NSRect)sourceRectForGlyph:(int)glyph {
	int tile = glyph2tile[glyph];
	return [self sourceRectForTile:tile];
}

- (NSRect)sourceRectForTile:(int)tile {
	int row = rows - 1 - tile/columns;
	int col = tile % columns;
	NSRect r = { col * tileSize.width, row * tileSize.height };
	r.size = tileSize;
	return r;
}

- (NSImage *)imageForGlyph:(int)glyph enabled:(BOOL)enabled
{
	// get image
	NSRect srcRect = [self sourceRectForGlyph:glyph];
	NSSize size = [self tileSize];
	if ( size.width > 32 || size.height > 32 ) {
		// since these images are used in menus we want to scale them down
		CGFloat m = size.width > size.height ? size.width : size.height;
		m = 32 / m;
		size.width  *= m;
		size.height *= m;
	}
	NSImage * newImage = [[[NSImage alloc] initWithSize:size] autorelease];
	NSRect dstRect = NSMakeRect(0, 0, size.width, size.height);
	[newImage lockFocus];
	[image drawInRect:dstRect fromRect:srcRect operation:NSCompositeCopy fraction:enabled ? 1.0f : 0.5];
	[newImage unlockFocus];
	return newImage;
}



- (void)dealloc {
	[image release];
	[super dealloc];
}

@end
