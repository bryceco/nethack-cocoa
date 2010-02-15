//
//  NhObject.m
//  NetHack
//
//  Created by dirk on 2/8/10.
//  Copyright 2010 Dirk Zimmermann. All rights reserved.
//

#import "NhObject.h"
#import "NSString+NetHack.h"

@implementation NhObject

@synthesize object;
@synthesize title;
@synthesize detail;
@synthesize inventoryLetter;
@synthesize glyph;

+ (id)objectWithTitle:(NSString *)t inventoryLetter:(char)invLet {
	return [[[self alloc] initWithTitle:t inventoryLetter:invLet] autorelease];
}

+ (id)objectWithObject:(struct obj *)obj {
	return [[[self alloc] initWithObject:obj] autorelease];
}

- (id)initWithTitle:(NSString *)t inventoryLetter:(char)invLet {
	if (self = [super init]) {
		title = [t copy];
		inventoryLetter = invLet;
	}
	return self;
}

- (id)initWithObject:(struct obj *)obj {
	NSString *tmp = [NSString stringWithFormat:@"%s", doname(obj)];
	NSArray *lines = [tmp splitNetHackDetails];
	if (self = [self initWithTitle:[lines objectAtIndex:0] inventoryLetter:obj->invlet]) {
		object = obj;
		inventoryLetter = object->invlet;
		if (lines.count == 2) {
			detail = [[lines objectAtIndex:1] copy];
		}
		glyph = obj_to_glyph(obj);
	}
	return self;
}

- (void)dealloc {
	[title release];
	[detail release];
	[super dealloc];
}

@end
