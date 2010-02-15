//
//  NhItemGroup.h
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

@class NhItem;

@interface NhItemGroup : NSObject {
	
	NSString *title;
	NSMutableArray *items;
	BOOL dummy;

}

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSArray *items;
@property (nonatomic, assign) BOOL dummy;

- (id) initWithTitle:(NSString *)t dummy:(BOOL)d;
- (id) initWithTitle:(NSString *)t;
- (void) addItem:(NhItem *)i;
- (void)removeItemAtIndex:(NSUInteger)row;

@end
