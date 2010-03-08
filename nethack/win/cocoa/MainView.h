//
//  MainView.h
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

#import <Cocoa/Cocoa.h>

@class MapView;
@class DirectionPad;

@interface MainView : NSView {

	int clipX;
	int clipY;
	
	NSSize tileSize;
	NSImage *petMark;

	NSTimer *	tooltipTimer;
	NSPoint		tooltipPoint;
	NSWindow *	tooltipWindow;
	
	BOOL		useAsciiMode;
	
	NSArray	*	asciiColors;
	NSFont	*	asciiFont;
}

- (void)cliparoundX:(int)x y:(int)y;
- (void)centerHero;
- (BOOL)setTileSet:(NSString *)tileSetName size:(NSSize)size;
- (NSFont *)asciiFont;
- (BOOL)setAsciiFont:(NSFont *)font;
- (void)enableAsciiMode:(BOOL)enable;

@end
