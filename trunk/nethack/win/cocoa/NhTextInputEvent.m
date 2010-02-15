//
//  NhTextInputEvent.m
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

#import "NhTextInputEvent.h"

@implementation NhTextInputEvent

@synthesize text;

+ (id)eventWithText:(NSString *)t {
	return [[[self alloc] initWithText:t] autorelease];
}

- (id)initWithText:(NSString *)t {
	if (self = [super initWithKey:-1]) {
		text = [t copy];
	}
	return self;
}

- (void)dealloc {
	[text release];
	[super dealloc];
}

@end
