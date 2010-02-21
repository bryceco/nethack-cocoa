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
#import "NhMapWindow.h"
#import "NhStatusWindow.h"


static NhWindow *s_messageWindow = nil;
static NhWindow *s_statusWindow = nil;
static NhWindow *s_mapWindow = nil;

@implementation NhWindow

@synthesize type;
@synthesize blocking;

+ (NhWindow *)messageWindow {
	if (s_messageWindow == nil) {
		s_messageWindow = [[NhWindow alloc] initWithType:NHW_MESSAGE];
	}
	return s_messageWindow;
}

+ (NhWindow *)statusWindow {
	if ( s_statusWindow == nil ) {
		s_statusWindow = [[NhStatusWindow alloc] initWithType:NHW_STATUS];
	}
	return s_statusWindow;
}

+ (NhWindow *)mapWindow {
	if (s_mapWindow == nil) {
		s_mapWindow = [[NhMapWindow alloc] initWithType:NHW_MAP];
	}
	return s_mapWindow;
}

- (BOOL)useAttributedStrings
{
	return type == NHW_MESSAGE;
}

- (id)initWithType:(int)t {
	if (self = [super init]) {
		type = t;
		lock = [[NSLock alloc] init];
		lines = [[NSMutableArray alloc] init];
		switch (t) {
			case NHW_MESSAGE:
				lineDelimiter = @"\n";
				break;
			case NHW_STATUS:
				lineDelimiter = @"\n";
				break;
			case NHW_MAP:
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

- (void)print:(const char *)str attr:(int)attr {
	NSString *s = [NSString stringWithCString:str encoding:NSASCIIStringEncoding];
	s = [s stringWithTrimmedWhitespaces];
	
	if ( [self useAttributedStrings] ) {

		NSDictionary * dict = nil;

		switch ( attr ) {
			case ATR_NONE:
				break;
			case ATR_BOLD:
				dict = [NSDictionary dictionaryWithObject:[NSFont boldSystemFontOfSize:[NSFont systemFontSize]]
												   forKey:NSFontAttributeName];
				break;
			case ATR_DIM:
			case ATR_ULINE:
				dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:NSUnderlineStyleSingle]
												   forKey:NSUnderlineStyleAttributeName];
				break;
			case ATR_BLINK:
			case ATR_INVERSE:
				dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSColor redColor], NSForegroundColorAttributeName,
						[NSColor blueColor], NSBackgroundColorAttributeName,
						nil];
				break;
		}
		NSAttributedString * s2 = [[[NSAttributedString alloc] initWithString:s attributes:dict] autorelease];
		s = (id)s2;
	}
			
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
	
	assert( ![self useAttributedStrings] );
	
	NSString * t = nil;
	NSArray *messages = [self messages];
	if (messages && messages.count > 0) {
		
		t = [messages componentsJoinedByString:lineDelimiter];
		
	}
	return t;
}

- (NSAttributedString *) attributedText {

	assert( [self useAttributedStrings] );
	
	NSArray *messages = [self messages];
	if (messages && messages.count > 0) {
		
		NSAttributedString * delim = [[NSMutableAttributedString alloc] initWithString:lineDelimiter];
		NSMutableAttributedString *t = nil;
		
		for ( NSAttributedString * msg in messages ) {
			if ( t == nil ) {
				t = [[[NSMutableAttributedString alloc] initWithString:@""] autorelease];
			} else {
				[t appendAttributedString:delim];
			}
			[t appendAttributedString:msg];
		} 
		
		[delim release];
		return t;
		
	} else {
		return nil;
	}
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
