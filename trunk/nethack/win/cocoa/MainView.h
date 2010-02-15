//
//  MainView.h
//  NetHack
//
//  Created by dirk on 2/1/10.
//  Copyright 2010 Dirk Zimmermann. All rights reserved.
//

@class MapView;
@class DirectionPad;

@interface MainView : NSView {

	int clipX;
	int clipY;
	
	CGSize tileSize;
	NSImage *petMark;
	
}

- (void)refreshMessages;
- (void)cliparoundX:(int)x y:(int)y;

@end
