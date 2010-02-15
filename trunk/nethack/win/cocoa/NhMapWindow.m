//
//  NhMapWindow.m
//  SlashEM
//
//  Created by dirk on 12/31/09.
//  Copyright 2009 Dirk Zimmermann. All rights reserved.
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

#import "NhMapWindow.h"

#include "hack.h"

@implementation NhMapWindow

- (id) initWithType:(int)t {
	if (self = [super initWithType:t]) {
		NSLog(@"map window %x", self);
		size_t numBytes = COLNO * ROWNO * sizeof(int);
		glyphs = malloc(numBytes);
		memset(glyphs, 0, numBytes);
	}
	return self;
}

- (void) printGlyph:(int)glyph atX:(XCHAR_P)x y:(XCHAR_P)y {
	glyphs[y * COLNO + x] = glyph;
}

- (int) glyphAtX:(XCHAR_P)x y:(XCHAR_P)y {
	return glyphs[y * COLNO + x];
}

- (void) clear {
	[super clear];
	size_t numBytes = COLNO * ROWNO * sizeof(int);
	memset(glyphs, 0, numBytes);
}

- (void) dealloc {
	free(glyphs);
	[super dealloc];
}

@end
