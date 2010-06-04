//
//  NhInventory.m
//  NetHack
//
//  Created by dirk on 2/8/10.
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

#import "NhInventory.h"
#import "NhObject.h"
#import "NSIndexPath+Z.h"

@implementation NhInventory

@synthesize objectClasses;

- (id)init {
	if (self = [super init]) {
		objectClasses = [[NSMutableArray alloc] init];
	}
	return self;
}

- (NSMutableArray *)arrayForClass:(char)class {
	if (!classArray[class]) {
		classArray[class] = [NSMutableArray array];
	}
	return classArray[class];
}

- (void)update {
	[objectClasses removeAllObjects];
	memset(classArray, (int) nil, sizeof(classArray));
	for (struct obj *otmp = invent; otmp; otmp = otmp->nobj) {
		NSMutableArray *array = [self arrayForClass:otmp->oclass];
		[array addObject:[NhObject objectWithObject:otmp]];
	}
	static const char classOrder[] = {
		WEAPON_CLASS, ARMOR_CLASS, WAND_CLASS, RING_CLASS, AMULET_CLASS, TOOL_CLASS, FOOD_CLASS,
		POTION_CLASS, SCROLL_CLASS, SPBOOK_CLASS, COIN_CLASS, GEM_CLASS, ROCK_CLASS, BALL_CLASS,
		CHAIN_CLASS, VENOM_CLASS
	};
	static const int numberOfClasses = sizeof(classOrder)/sizeof(char);
	for (int i = 0; i < numberOfClasses; ++i) {
		NSArray *items = classArray[i];
		if (items) {
			[objectClasses addObject:items];
		}
	}
	
	// Hands / Gold
	NSArray *specialObjects = nil;
	if (u.ugold) {
		specialObjects = [NSArray arrayWithObjects:[NhObject objectWithTitle:@"Gold" inventoryLetter:'$' group_accel:0],
						  [NhObject objectWithTitle:@"Hands" inventoryLetter:'-' group_accel:0], nil];
	} else {
		specialObjects = [NSArray arrayWithObject:[NhObject objectWithTitle:@"Hands" inventoryLetter:'-' group_accel:0]];
	}
	[objectClasses addObject:specialObjects];
}

- (NhObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
	return [[objectClasses objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
}

- (BOOL)containsObjectClass:(char)oclass {
	return classArray[oclass] != nil;
}

- (void)dealloc {
	[objectClasses release];
	[super dealloc];
}

@end
