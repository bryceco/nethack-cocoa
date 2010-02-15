//
//  MainViewController.h
//  NetHack
//
//  Created by dirk on 2/1/10.
//  Copyright 2010 Dirk Zimmermann. All rights reserved.
//

#import "ZDirection.h"

@class NhYnQuestion;
@class MainView;
@class NhWindow;
@class ActionViewController;
@class InventoryViewController;
@class NhMenuWindow;
@class MenuViewController;

@interface MainViewController : NSViewController {

	NhYnQuestion *currentYnQuestion;
	MainView *mainView;
	
	BOOL directionQuestion;
	
}

+ (MainViewController *) instance;

// window API

- (void)handleDirectionQuestion:(NhYnQuestion *)q;
- (void)showYnQuestion:(NhYnQuestion *)q;
- (void)refreshMessages;
// gets called when core waits for input
- (void)refreshAllViews;
- (void)displayWindow:(NhWindow *)w;
- (void)showMenuWindow:(NhMenuWindow *)w;
- (void)clipAroundX:(int)x y:(int)y;
- (void)updateInventory;
- (void)getLine;

// touch handling
- (void)handleMapTapTileX:(int)x y:(int)y forLocation:(CGPoint)p inView:(NSView *)view;
- (void)handleDirectionTap:(e_direction)direction;
- (void)handleDirectionDoubleTap:(e_direction)direction;

@end
