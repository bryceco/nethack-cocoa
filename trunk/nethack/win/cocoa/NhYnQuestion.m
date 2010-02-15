//
//  NhYnQuestion.m
//  SlashEM
//
//  Created by dirk on 12/30/09.
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

#import "NhYnQuestion.h"

@implementation NhYnQuestion

@synthesize question, choices;

- (id) initWithQuestion:(const char *)q choices:(const char *)ch default:(int)def {
	if (self = [super init]) {
		question = [[NSString alloc] initWithCString:q encoding:NSASCIIStringEncoding];
		choices = ch;
	}
	return self;
}

- (void) dealloc {
	[question release];
	[super dealloc];
}

@end
