//
//  NSIndexPath+Z.h
//  NetHackCocoa
//
//  Created by Dirk Zimmermann on 2/15/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface NSIndexPath (Z)

@property (nonatomic, readonly) NSUInteger section;
@property (nonatomic, readonly) NSUInteger row;

- (NSUInteger)section;
- (NSUInteger)row;

@end
