//
//  Action.m
//  NetHack
//
//  Created by dirk on 2/4/10.
//  Copyright 2010 Dirk Zimmermann. All rights reserved.
//

#import "Action.h"

@implementation Action

@synthesize title;

- (id)initWithTitle:(NSString *)t {
	if (self = [super init]) {
		title = [t copy];
	}
	return self;
}

- (NSMutableArray *)invocations {
	if (!invocations) {
		invocations = [[NSMutableArray alloc] init];
	}
	return invocations;
}

- (void)invoke:(id)sender {
	if (invocations.count > 0) {
		for (NSInvocation *inv in invocations) {
			[inv invoke];
		}
	}
}

- (void)addTarget:(id)target action:(SEL)action arg:(id)arg {
	NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[target methodSignatureForSelector:action]];
	[inv setTarget:target];
	[inv setSelector:action];
	if (arg) {
		[inv setArgument:&arg atIndex:2];
	}
	[inv retainArguments];
	[self.invocations addObject:inv];
}

- (void)addInvocation:(NSInvocation *)inv {
	[self.invocations addObject:inv];
}

- (void)dealloc {
	[title release];
	if (invocations) { // guard against auto-creation
		[invocations release];
	}
	[super dealloc];
}

@end
