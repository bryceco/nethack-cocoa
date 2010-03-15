//
//  EquipmentView.h
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

#import <Cocoa/Cocoa.h>


@interface EquipmentView : NSView {
	IBOutlet NSImageView *	helmet;
	IBOutlet NSImageView *	blindfold;	// blindfold, lenses, towel
	IBOutlet NSImageView *	ringLeft;
	IBOutlet NSImageView *	ringRight;
	IBOutlet NSImageView *	amulet;
	IBOutlet NSImageView *	weaponHand;
	IBOutlet NSImageView *	alternateHand;	// shield or alternate weapon
	IBOutlet NSImageView *	shirt;
	IBOutlet NSImageView *	cloak;
	IBOutlet NSImageView *	armor;
	IBOutlet NSImageView *	gloves;
	IBOutlet NSImageView *	boots;
}

- (void)updateInventory;

@end
