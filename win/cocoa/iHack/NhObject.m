//
//  NhObject.m
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

#import "NhObject.h"
#import "NSString+NetHack.h"

@implementation NhObject

@synthesize object;
@synthesize title;
@synthesize detail;
@synthesize inventoryLetter;
@synthesize glyph;
@synthesize group_ch;

+ (id)objectWithTitle:(NSString *)t inventoryLetter:(char)invLet group_accel:(char)group_accel {
	return [[[self alloc] initWithTitle:t inventoryLetter:invLet group_accel:group_accel] autorelease];
}

+ (id)objectWithObject:(struct obj *)obj {
	return [[[self alloc] initWithObject:obj] autorelease];
}

- (id)initWithTitle:(NSString *)t inventoryLetter:(char)invLet group_accel:(char)group_accel {
	if (self = [super init]) {
		title = [t copy];
		inventoryLetter = invLet;
		group_ch = group_accel;
	}
	return self;
}

- (id)initWithObject:(struct obj *)obj {
	NSString *tmp = [NSString stringWithFormat:@"%s", doname(obj)];
	NSArray *lines = [tmp splitNetHackDetails];
	if (self = [self initWithTitle:[lines objectAtIndex:0] inventoryLetter:obj->invlet group_accel:0]) {
		object = obj;
		inventoryLetter = object->invlet;
		if (lines.count == 2) {
			detail = [[lines objectAtIndex:1] copy];
		}
		glyph = obj_to_glyph(obj,rn2);
	}
	return self;
}

- (void)setTitle:(NSString *)t
{
	[title release];
	title = [t copy];
}

- (void)setInventoryLetter:(char)ch
{
	inventoryLetter = ch;
}

- (void)dealloc {
	[title release];
	[detail release];
	[super dealloc];
}

@end
