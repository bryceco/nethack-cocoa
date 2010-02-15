//
//  NhItem.h
//  SlashEM
//
//  Created by dirk on 1/4/10.
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

#import <Foundation/Foundation.h>
#import "NhObject.h"

#include "hack.h"

@interface NhItem : NhObject {
	
	ANY_P identifier;
	int amount;
	int maxAmount;
	BOOL selected;

}

@property (nonatomic, readonly) ANY_P identifier;
@property (nonatomic, assign) int amount;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, readonly) int maxAmount;

- (id)initWithTitle:(NSString *)t identifier:(ANY_P)ident glyph:(int)g selected:(BOOL)s;

@end
