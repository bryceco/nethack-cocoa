//
//  NhCommand.h
//  SlashEM
//
//  Created by dirk on 1/13/10.
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
#import "Action.h"
#import "wincocoa.h"

#ifndef M
# ifndef NHSTDC
#  define M(c)		(0x80 | (c))
# else
#  define M(c)		((c) - 128)
# endif /* NHSTDC */
#endif
#ifndef C
#define C(c)		(0x1f & (c))
#endif

@interface NhCommand : Action {
	
	char *keys;

}

@property (nonatomic, readonly) const char *keys;

+ (id)commandWithTitle:(const char *)t keys:(const char *)c;
+ (id)commandWithTitle:(const char *)t key:(char)c;

// all commands possible at this stage
+ (NSArray *)currentCommands;

// all commands possible for an adjacent position
+ (NSArray *)commandsForAdjacentTile:(coord)tp;

- (id)initWithTitle:(const char *)t keys:(const char *)c;
- (id)initWithTitle:(const char *)t key:(char)c;

@end
