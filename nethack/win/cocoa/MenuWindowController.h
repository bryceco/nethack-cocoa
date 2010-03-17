//
//  MenuWindowController.h
//  NetHackCocoa
//
//  Created by Bryce on 2/16/10.
//  Copyright 2010 Bryce Cogswell. All rights reserved.
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


#import <Cocoa/Cocoa.h>
#import "NhMenuWindow.h"

@interface MenuWindowController : NSWindowController <NSWindowDelegate> {
	
	NhMenuWindow		*	menuParams;
	
	NSMutableDictionary	*	itemDict;
	
	IBOutlet NSView		*	menuView;
	IBOutlet NSButton	*	cancelButton;
	IBOutlet NSButton	*	acceptButton;

	IBOutlet NSButton	*	selectAll;
}

+ (void)menuWindowWithMenu:(NhMenuWindow *)menu;

-(IBAction)doAccept:(id)sender;
-(IBAction)doCancel:(id)sender;
-(IBAction)selectAll:(id)sender;
-(IBAction)selectUnknownBUC:(id)sender;

@end
