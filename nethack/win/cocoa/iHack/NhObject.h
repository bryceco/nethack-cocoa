//
//  NhObject.h
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

#import <Foundation/Foundation.h>
#include "hack.h"

@interface NhObject : NSObject {
	
	struct obj *object;
	NSString *title;
	NSString *detail;
	char inventoryLetter;
	char group_ch; 
	int glyph;

}

@property (nonatomic, readonly) struct obj *object;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *detail;
@property (nonatomic, readonly) char inventoryLetter;
@property (nonatomic, readonly) char group_ch;
@property (nonatomic, readonly) int glyph;

+ (id)objectWithTitle:(NSString *)t inventoryLetter:(char)invLet group_accel:(char)group_accel;
+ (id)objectWithObject:(struct obj *)obj;

- (id)initWithTitle:(NSString *)t inventoryLetter:(char)invLet group_accel:(char)group_accel;
- (id)initWithObject:(struct obj *)obj;
- (void)setTitle:(NSString *)title;
- (void)setInventoryLetter:(char)ch;

@end
