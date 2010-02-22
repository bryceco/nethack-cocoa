//
//  PlayerSelectionWindowController.h
//  NetHackCocoa
//
//  Created by Bryce on 2/21/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PlayerSelectionWindowController : NSWindowController <NSWindowDelegate, NSTableViewDataSource, NSTableViewDelegate> {

	int							cntRoles;
	int							cntRaces;
		
	BOOL					*	raceEnabled;
	BOOL					*	roleEnabled;
	
	NSButtonCell			*	gender[2];
	NSButtonCell			*	alignment[3];
	IBOutlet NSTextField	*	name;
	IBOutlet NSTableView	*	race;
	IBOutlet NSTableView	*	role;
	IBOutlet NSButtonCell	*	sexMale;
	IBOutlet NSButtonCell	*	sexFemale;
	IBOutlet NSButtonCell	*	alignLawful;
	IBOutlet NSButtonCell	*	alignNeutral;
	IBOutlet NSButtonCell	*	alignChaotic;
}

-(IBAction)buttonSelect:(id)sender;

-(void)runModal;

-(IBAction)doAccept:(id)sender;
-(IBAction)doCancel:(id)sender;

@end
