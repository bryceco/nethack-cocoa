//
//  NhObject.h
//  NetHack
//
//  Created by dirk on 2/8/10.
//  Copyright 2010 Dirk Zimmermann. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "hack.h"

@interface NhObject : NSObject {
	
	struct obj *object;
	NSString *title;
	NSString *detail;
	char inventoryLetter;
	int glyph;

}

@property (nonatomic, readonly) struct obj *object;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *detail;
@property (nonatomic, readonly) char inventoryLetter;
@property (nonatomic, readonly) int glyph;

+ (id)objectWithTitle:(NSString *)t inventoryLetter:(char)invLet;
+ (id)objectWithObject:(struct obj *)obj;

- (id)initWithTitle:(NSString *)t inventoryLetter:(char)invLet;
- (id)initWithObject:(struct obj *)obj;

@end
