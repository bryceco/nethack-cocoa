//
//  NhInventory.h
//  NetHack
//
//  Created by dirk on 2/8/10.
//  Copyright 2010 Dirk Zimmermann. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "hack.h"

@class NhObject;

@interface NhInventory : NSObject {
	
	NSMutableArray *objectClasses;
	NSMutableArray *classArray[MAXOCLASSES];
	
}

@property (nonatomic, readonly) NSArray *objectClasses;

- (void)update;
- (NhObject *)objectAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)containsObjectClass:(char)oclass;

@end
