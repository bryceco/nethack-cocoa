//
//  MainViewController.h
//  NetHack
//
//  Created by dirk on 2/1/10.
//  Copyright 2010 Dirk Zimmermann. All rights reserved.
//

/*
 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#import "ZDirection.h"

@class NhYnQuestion;
@class MainView;
@class NhWindow;
@class NhMenuWindow;
@class MenuWindowController;
@class MessageWindowController;
@class DirectionWindowController;
@class YesNoWindowController;
@class InputWindowController;
@class ExtCommandWindowController;
@class PlayerSelectionWindowController;

@interface MainWindowController : NSWindowController <NSWindowDelegate,NSMenuDelegate> {

	BOOL									isDirectionQuestion;
	
	IBOutlet MainView						*	mainView;
	IBOutlet NSScrollView					*	scrollView;
	IBOutlet NSTextView						*	messagesView;
	IBOutlet NSTextField					*	statusView;
	IBOutlet NSMenu							*	tileSetMenu;
	
	IBOutlet DirectionWindowController		*	directionWindow;
	IBOutlet YesNoWindowController			*	yesNoWindow;
	IBOutlet InputWindowController			*	inputWindow;
	IBOutlet ExtCommandWindowController		*	extCommandWindow;
	IBOutlet PlayerSelectionWindowController*	showPlayerSelection;
}

+ (MainWindowController *) instance;


// menu
- (IBAction)performMenuAction:(id)sender;
- (IBAction)terminateApplication:(id)sender;
- (IBAction)addTileSet:(id)sender;

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
- (void)displayMessageWindow:(NSString *)text;
- (void)showExtendedCommands;
- (void)showPlayerSelection;
- (void)showDirectionWithPrompt:(NSString *)prompt;


// touch handling
- (void)handleMapTapTileX:(int)x y:(int)y forLocation:(CGPoint)p inView:(NSView *)view;
- (void)handleDirectionTap:(e_direction)direction;
- (void)handleDirectionDoubleTap:(e_direction)direction;

@end
