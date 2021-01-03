//
//  NhEvent.h
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

#import <Foundation/Foundation.h>

@interface NhEvent : NSObject {
	
	int key;
	int mod;
	int x;
	int y;

}

@property (nonatomic, readonly) int key;
@property (nonatomic, readonly) int mod;
@property (nonatomic, readonly) int x;
@property (nonatomic, readonly) int y;
@property (nonatomic, readonly) BOOL isKeyEvent;

+ (id) eventWithKeychar:(int)k mod:(int)m x:(int)i y:(int)j;
+ (id) eventWithX:(int)i y:(int)j;
+ (id) eventWithKeychar:(int)k;

- (instancetype) initWithKey:(int)k mod:(int)m x:(int)i y:(int)j;
- (instancetype) initWithX:(int)i y:(int)j;
- (instancetype) initWithKeychar:(int)k;

@end
