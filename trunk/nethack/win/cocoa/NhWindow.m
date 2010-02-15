//
//  NhWindow.m
//  SlashEM
//
//  Created by dirk on 12/30/09.
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

#import "NhWindow.h"
#include "hack.h"
#import "NSString+Z.h"

static NhWindow *s_root = nil;
static NhWindow *s_messageWindow = nil;
static NhWindow *s_statusWindow = nil;
static NhWindow *s_mapWindow = nil;

@implementation NhWindow

@synthesize type;
@synthesize blocking;

+ (void)initialize {
	s_root = [[NhWindow alloc] initWithType:0];
}

+ (NhWindow *)root {
	return s_root;
}

+ (NhWindow *)messageWindow {
	if (s_messageWindow) {
		return s_messageWindow;
	}
	return s_root;
}

+ (NhWindow *)statusWindow {
	return s_statusWindow;
}

+ (NhWindow *)mapWindow {
	return s_mapWindow;
}

- (id)initWithType:(int)t {
	if (self = [super init]) {
		type = t;
		lock = [[NSLock alloc] init];
		lines = [[NSMutableArray alloc] init];
		switch (t) {
			case NHW_MESSAGE:
				s_messageWindow = self;
				lineDelimiter = @"\n";
				break;
			case NHW_STATUS:
				s_statusWindow = self;
				lineDelimiter = @" ";
				break;
			case NHW_MAP:
				s_mapWindow = self;
				lineDelimiter = @" ";
				break;
			case NHW_TEXT:
			case NHW_MENU:
				lineDelimiter = @"\n";
				break;
			default:
				lineDelimiter = @" ";
		}
	}
	return self;
}

- (void)print:(const char *)str {
	NSString *s = [NSString stringWithCString:str encoding:NSASCIIStringEncoding];
	s = [s stringWithTrimmedWhitespaces];
	[self lock];
	[lines addObject:s];
	[self unlock];
}

- (NSArray *)messages {
	NSArray *res = nil;
	[self lock];
	if (lines.count > 0) {
		res = [NSArray arrayWithArray:lines];
	}
	[self unlock];
	return res;
}

- (void)clear {
	// message window
	[self lock];
	if (lines.count > 20) {
		while (lines.count > 20) {
			[lines removeObjectAtIndex:0];
		}
	}
	[self unlock];
}

- (NSString *) text {
	NSString *t = nil;
	NSArray *messages = [self messages];
	if (messages && messages.count > 0) {
		t = [messages componentsJoinedByString:lineDelimiter];
	}
	return t;
}

- (void)lock {
	[lock lock];
}

- (void)unlock {
	[lock unlock];
}

- (void)dealloc {
	[lines release];
	[lock release];
	[super dealloc];
}

@end
