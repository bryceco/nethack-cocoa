//
//  NSString+Regexp.m
//  SlashEM
//
//  Created by dirk on 8/6/09.
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

#import "NSString+Z.h"

@implementation NSString (Z)

- (BOOL) containsString:(NSString *)s {
	NSRange r = [self rangeOfString:s];
	if (r.location != NSNotFound) {
		return YES;
	}
	return NO;
}

- (BOOL) startsWithString:(NSString *)s {
	NSRange r = [self rangeOfString:s];
	return r.location == 0;
}

- (BOOL) containsChar:(char)c {
	int length = self.length;
	for (int i = 0; i < length; ++i) {
		char ct = [self characterAtIndex:i];
		if (ct == c) {
			return YES;
		}
	}
	return NO;
}

- (BOOL) endsWithString:(NSString *)s {
	NSRange r = [self rangeOfString:s];
	if (r.location != NSNotFound) {
		return r.location == self.length-s.length;
	}
	return NO;
}

- (NSString *) substringBetweenDelimiters:(NSString *)del {
	char c = [del characterAtIndex:0];
	NSString *s = [NSString stringWithFormat:@"%c", c];
	NSRange r1 = [self rangeOfString:s];
	if (r1.location == NSNotFound) {
		return nil;
	}
	c = [del characterAtIndex:1];
	s = [NSString stringWithFormat:@"%c", c];
	NSRange r2 = [self rangeOfString:s];
	if (r2.location == NSNotFound) {
		return nil;
	}
	if (r2.location > r1.location) {
		NSRange r = NSMakeRange(r1.location+1, r2.location-r1.location-1);
		NSString *sub = [self substringWithRange:r];
		return sub;
	} else {
		return nil;
	}
}

- (NSString *) substringStartingWithString:(NSString *)start {
	NSRange r1 = [self rangeOfString:start];
	if (r1.location == NSNotFound) {
		return nil;
	}
	return [self substringFromIndex:r1.location];
}

- (NSString *) stringWithTrimmedWhitespaces {
	NSMutableString *s1 = [NSMutableString stringWithCapacity:1];
	BOOL wasSpace = NO;
	for (int i = 0; i < self.length; ++i) {
		char c = [self characterAtIndex:i];
		if (!wasSpace) {
			[s1 appendFormat:@"%c", c];
			if (c == ' ') {
				wasSpace = YES;
			}
		} else {
			if (c != ' ') {
				wasSpace = NO;
				[s1 appendFormat:@"%c", c];
			}
		}
	}
	return s1;
}

@end
