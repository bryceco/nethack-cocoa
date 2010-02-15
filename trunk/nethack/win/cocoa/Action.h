//
//  Action.h
//  NetHack
//
//  Created by dirk on 2/4/10.
//  Copyright 2010 Dirk Zimmermann. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Action : NSObject {
	
	NSString *title;
	NSMutableArray *invocations;

}

@property (nonatomic, readonly) NSString *title;

- (id)initWithTitle:(NSString *)t;
- (void)invoke:(id)sender;
- (void)addTarget:(id)target action:(SEL)action arg:(id)arg;
- (void)addInvocation:(NSInvocation *)inv;

@end
