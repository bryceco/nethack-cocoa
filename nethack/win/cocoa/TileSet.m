//
//  TileSet.m
//  SlashEM
//
//  Created by dirk on 1/17/10.
//  Copyright 2010 Dirk Zimmermann. All rights reserved.
//

//  This file is part of Slash'EM.
//
//  Slash'EM is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, version 2 of the License only.
//
//  Slash'EM is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Slash'EM.  If not, see <http://www.gnu.org/licenses/>.

#import "TileSet.h"

static TileSet *s_instance = nil;

@implementation TileSet

@synthesize image;

+ (TileSet *)instance {
	return s_instance;
}

+ (void)setInstance:(TileSet *)ts {
	[s_instance release];
	s_instance = ts;
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
	int row = tile/columns;
	int col = row ? tile % columns : tile;
	NSRect r = { col * tileSize.width, row * tileSize.height };
	r.size = tileSize;
	return r;
}

- (void)dealloc {
	[image release];
	[super dealloc];
}

@end
