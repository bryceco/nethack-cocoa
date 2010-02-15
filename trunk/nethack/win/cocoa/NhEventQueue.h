//
//  NhEventQueue.h
//  SlashEM
//
//  Created by dirk on 12/31/09.
//  Copyright 2009 Dirk Zimmermann. All rights reserved.
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

@class NhEvent;
@class NhCommand;

@interface NhEventQueue : NSObject {
	
	NSMutableArray *events;
	NSCondition *condition;

}

+ (NhEventQueue *)instance;

- (void)addEvent:(NhEvent *)e;
- (void)addKey:(int)k;
- (void)addEscapeKey;
- (void)addKeys:(const char *)keys;
- (void)addCommand:(NhCommand *)cmd;
- (NhEvent *)nextEvent;
- (void)waitForNextEvent;

// non-blocking
- (NhEvent *)peek;

@end
