//
//  NhInventory.m
//  NetHack
//
//  Created by dirk on 2/8/10.
//  Copyright 2010 Dirk Zimmermann. All rights reserved.
//

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
		specialObjects = [NSArray arrayWithObjects:[NhObject objectWithTitle:@"Gold" inventoryLetter:'$'],
						  [NhObject objectWithTitle:@"Hands" inventoryLetter:'-'], nil];
	} else {
		specialObjects = [NSArray arrayWithObject:[NhObject objectWithTitle:@"Hands" inventoryLetter:'-']];
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
