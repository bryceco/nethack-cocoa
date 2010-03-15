//
//  EquipmentView.m
//  NetHackCocoa
//
//  Created by Bryce on 3/14/10.
//  Copyright 2010 Bryce Cogswell All rights reserved.
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

#import "hack.h"
#import "EquipmentView.h"
#import "TileSet.h"

@implementation EquipmentView

- (id)initWithFrame:(NSRect)frame 
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect 
{
}

- (void)updateSlot:(NSImageView *)slot item:(struct obj *)item text:(NSString *)text
{
	NSImage * image = nil;
	if ( item ) {
		int glyph = obj_to_glyph(item);
		if ( glyph != NO_GLYPH ) {
			image = [[TileSet instance] imageForGlyph:glyph enabled:YES];
			char * s = doname(item);
			text = [NSString stringWithUTF8String:s];
		}
	}
	[slot setImage:image];
	[slot setToolTip:text];
}

- (void)updateInventory
{
	[self updateSlot:weaponHand		item:uwep		text:@"weapon"];
	if ( u.twoweap )
		[self updateSlot:alternateHand	item:uswapwep	text:@"2nd weapon"];
	else
		[self updateSlot:alternateHand	item:uarms	text:@"shield"];
	[self updateSlot:shirt			item:uarmu		text:@"shirt"];
	[self updateSlot:cloak			item:uarmc		text:@"cloak"];
	[self updateSlot:helmet			item:uarmh		text:@"helmet"];
	[self updateSlot:gloves			item:uarmg		text:@"gloves"];
	[self updateSlot:boots			item:uarmf		text:@"boots"];
	[self updateSlot:ringRight		item:uright		text:@"left ring"];
	[self updateSlot:ringLeft		item:uleft		text:@"right ring"];
	[self updateSlot:blindfold		item:ublindf	text:@"blindfold/lenses"];
	[self updateSlot:amulet			item:uamul		text:@"amulet"];
	[self updateSlot:armor			item:uarm		text:@"armor"];
	 
	//	uquiver 
	//	uchain
	//	uball
}

@end
