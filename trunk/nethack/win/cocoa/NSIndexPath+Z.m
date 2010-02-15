//
//  NSIndexPath+Z.m
//  NetHackCocoa
//
//  Created by Dirk Zimmermann on 2/15/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "NSIndexPath+Z.h"

@implementation NSIndexPath (Z)

- (NSUInteger)section {
	return [self indexAtPosition:0];
}

- (NSUInteger)row {
	return [self indexAtPosition:1];
}

@end
