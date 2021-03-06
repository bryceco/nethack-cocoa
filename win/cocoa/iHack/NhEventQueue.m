//
//  NhEventQueue.m
//  SlashEM
//
//  Created by dirk on 12/31/09.
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

#import "NhEventQueue.h"
#import "NhEvent.h"
#import "NhCommand.h"
#import "NetHackCocoaAppDelegate.h"
#import "MainWindowController.h"

static NhEventQueue *s_eventQueue;

@implementation NhEventQueue

+ (void) initialize {
	s_eventQueue = [[self alloc] init];
}

+ (NhEventQueue *) instance {
	return s_eventQueue;
}

- (id) init {
	if (self = [super init]) {
		condition = [[NSCondition alloc] init];
		events = [[NSMutableArray alloc] init];
		appDelegate = [MainWindowController instance].appDelegate;
	}
	return self;
}

- (void) addEvent:(NhEvent *)e {
	[condition lock];
	[events addObject:e];
	[condition signal];
	[condition unlock];
}

- (void) addKey:(int)k {
	[self addEvent:[NhEvent eventWithKeychar:k]];
}

- (void)addEscapeKey {
	[self addKey:'\033'];
}

- (void)addKeys:(const char *)keys {
	[condition lock];
	const char *pStr = keys;
	while (*pStr) {
		[events addObject:[NhEvent eventWithKeychar:*pStr]];
		pStr++;
	}
	[condition signal];
	[condition unlock];
}

- (NhEvent *) nextEvent {
	
	[appDelegate unlockNethackCore];
	
	[condition lock];
	while (events.count == 0) {
		[condition wait];
	}
	NhEvent *e = [events objectAtIndex:0];
	[events removeObjectAtIndex:0];
	[condition unlock];
	
	[appDelegate lockNethackCore];
	
	return e;
}

- (void)waitForNextEvent {
	
	[appDelegate unlockNethackCore];
	
	[condition lock];
	while (events.count == 0) {
		[condition wait];
	}
	[condition unlock];
	
	[appDelegate lockNethackCore];
}

- (void) addCommand:(NhCommand *)cmd {
	[self addKeys:cmd.keys];
}

- (NhEvent *)peek {
	if (events.count > 0) {
		return [events objectAtIndex:0];
	}
	return nil;
}

@end
