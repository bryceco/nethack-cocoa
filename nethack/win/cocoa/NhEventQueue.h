//
//  NhEventQueue.h
//  SlashEM
//
//  Created by dirk on 12/31/09.
//  Copyright 2010 Dirk Zimmermann. All rights reserved.
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
