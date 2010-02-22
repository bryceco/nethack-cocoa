//
//  PlayerSelectionWindowController.m
//  NetHackCocoa
//
//  Created by Bryce on 2/21/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "PlayerSelectionWindowController.h"
#import "TileSet.h"

#include "hack.h"

@implementation PlayerSelectionWindowController




-(void)selectGender:(int)g
{
	flags.initgend = g;
}

-(void)selectAlignment:(int)a
{
	flags.initalign = a;	
}


-(void)setupOthers
{
    int ro = [role selectedRow];
    int ra = [race selectedRow];
    int valid = -1;
    int c = 0;
    for ( int j = 0; j<ROLE_GENDERS; j++) {
		bool v = validgend(ro,ra,j);
		if ( [gender[j] state] )
			c = j;
		[gender[j] setEnabled:v];
		if ( valid<0 && v ) 
			valid = j;
    }
    if ( !validgend(ro,ra,c) )
		c = valid;
    for ( int k = 0; k<ROLE_GENDERS; k++) {
		[gender[k] setState:c==k];
    }
    [self selectGender:c];
	
    valid = -1;
    for ( int j=0; j<ROLE_ALIGNS; j++) {
		bool v = validalign(ro,ra,j);
		if ( [alignment[j] state] )
			c = j;
		[alignment[j] setEnabled:v];
		if ( valid<0 && v )
			valid = j;
    }
    if ( !validalign(ro,ra,c) )
		c = valid;
    for ( int k=0; k<ROLE_ALIGNS; k++) {
		[alignment[k] setState:c==k];
    }
    [self selectAlignment:c];
}


-(void)selectRace
{
    int ra = [race selectedRow];
    int ro = [role selectedRow];
	
    if (ra >= 0 && ro >= 0)  {
		
		[race setDelegate:nil];
		[role setDelegate:nil];
		
		int valid = -1;
		for ( int j = 0; j < cntRoles; j++) {
			bool v = validrace(j,ra);
			roleEnabled[j] = v;
			if ( valid < 0 && v )
				valid = j;
		}
		
		if ( !roleEnabled[ro] ) {
			ro = valid;
		}
		[race selectRowIndexes:[NSIndexSet indexSetWithIndex:ra] byExtendingSelection:NO];
		[role selectRowIndexes:[NSIndexSet indexSetWithIndex:ro] byExtendingSelection:NO];
		
		flags.initrace = ra;
		
		[race setDelegate:self];
		[role setDelegate:self];
		
		[race setNeedsDisplay];
		[role setNeedsDisplay];
	}
	
	[self setupOthers];
}

-(void)selectRole
{
    int ra = [race selectedRow];
    int ro = [role selectedRow];
	
    if (ra >= 0 && ro >= 0)  {
		
		[race setDelegate:nil];
		[role setDelegate:nil];
		
		int valid = -1;
		for ( int j = 0; j < cntRaces; j++) {
			bool v = validrace(ro,j);
			raceEnabled[j] = v;
			if ( valid < 0 && v )
				valid = j;
		}
		if ( !raceEnabled[ra] ) {
			ra = valid;
		}
		[race selectRowIndexes:[NSIndexSet indexSetWithIndex:ra] byExtendingSelection:NO];
		[role selectRowIndexes:[NSIndexSet indexSetWithIndex:ro] byExtendingSelection:NO];
		
		flags.initrole = ro;
		
		[race setDelegate:self];
		[role setDelegate:self];
		
		[race setNeedsDisplay];
		[role setNeedsDisplay];	
	}
	[self setupOthers];
}


-(void)selectInitialPlayer
{
	BOOL fully_specified_role = YES;

	gender[0] = sexMale;
	gender[1] = sexFemale;

	alignment[0] = alignLawful;
	alignment[1] = alignNeutral;
	alignment[2] = alignChaotic;
	
	if ( strncmp(plname,"player",6) && strncmp(plname,"games",5) ) {
		[name setStringValue:[NSString stringWithUTF8String:plname]];;
	}
		
	// count roles and races
	for ( cntRaces = 0; races[cntRaces].noun; cntRaces++ )
		continue;
	for ( cntRoles = 0; roles[cntRoles].name.m; cntRoles++ )
		continue;
	
	raceEnabled = (BOOL *)malloc( cntRaces*sizeof(BOOL) );
	roleEnabled = (BOOL *)malloc( cntRoles*sizeof(BOOL) );
	for ( int i = 0; i < cntRaces; ++i )
		raceEnabled[i] = YES;
	for ( int i = 0; i < cntRoles; ++i )
		roleEnabled[i] = YES;
	

	// set table row height based on tiles
	CGFloat rowHeight = [[TileSet instance] tileSize].height;
	if ( rowHeight > 32 )
		rowHeight = 32;
	[role setRowHeight:rowHeight];
	[race setRowHeight:rowHeight];
	
    // Randomize race and role, unless specified in config
    int ro = flags.initrole;
    if (ro == ROLE_NONE || ro == ROLE_RANDOM) {
		ro = rn2(cntRoles);
		if (flags.initrole != ROLE_RANDOM) {
			fully_specified_role = FALSE;
		}
    }
    int ra = flags.initrace;
    if (ra == ROLE_NONE || ra == ROLE_RANDOM) {
		ra = rn2(cntRaces);
		if (flags.initrace != ROLE_RANDOM) {
			fully_specified_role = FALSE;
		}
    }
	
    // make sure we have a valid combination, honoring 
    // the users request if possible.
    bool choose_race_first = FALSE;
    if (flags.initrace >= 0 && flags.initrole < 0) {
		choose_race_first = TRUE;
    }
    while (!validrace(ro,ra)) {
		if (choose_race_first) {
			ro = rn2(cntRoles);
			if (flags.initrole != ROLE_RANDOM) {
				fully_specified_role = FALSE;
			}
		} else {
			ra = rn2(cntRaces);
			if (flags.initrace != ROLE_RANDOM) {
				fully_specified_role = FALSE;
			}
		}
    }
	
    int g = flags.initgend;
    if (g == -1) {
		g = rn2(ROLE_GENDERS);
		fully_specified_role = FALSE;
    }
    while (!validgend(ro,ra,g)) {
		g = rn2(ROLE_GENDERS);
    }
	[gender[g] setState:NSOnState];
	[self selectGender:g];
	
    int a = flags.initalign;
    if (a == -1) {
		a = rn2(ROLE_ALIGNS);
		fully_specified_role = FALSE;
    }
    while (!validalign(ro,ra,a)) {
		a = rn2(ROLE_ALIGNS);
    }
	
    [alignment[a] setState:NSOnState];
	[self selectAlignment:a];
	
	[role selectRowIndexes:[NSIndexSet indexSetWithIndex:ro] byExtendingSelection:NO];
	[race selectRowIndexes:[NSIndexSet indexSetWithIndex:ra] byExtendingSelection:NO];
	
    flags.initrace = ra;
    flags.initrole = ro;
}



- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	if ( aTableView == race ) {
		return cntRaces;
	} else {
		return cntRoles;
	}
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	int glyph;
	const char * text;
	BOOL male = [sexMale state] == NSOnState;
	BOOL enabled;

	if ( aTableView == race ) {
		text = races[rowIndex].noun;
		glyph = monnum_to_glyph( male || races[rowIndex].femalenum < 0 ? races[rowIndex].malenum : races[rowIndex].femalenum);
		enabled = raceEnabled[ rowIndex ];
	} else {
		text = male || roles[rowIndex].name.f == NULL ? roles[rowIndex].name.m : roles[rowIndex].name.f;
		glyph = monnum_to_glyph(male || roles[rowIndex].femalenum < 0 ? roles[rowIndex].malenum : roles[rowIndex].femalenum);
		enabled = roleEnabled[ rowIndex ];
	}
	
	// get image
	NSImage * image = [[TileSet instance] imageForGlyph:glyph];
	NSString * title = [NSString stringWithFormat:@" %s",text];
	
	if ( !enabled )
		title = [NSString stringWithFormat:@"%@ (x)", title];
	
	// create attributed string with glyph
	NSTextAttachment * attachment = [[NSTextAttachment alloc] init];
	[(NSCell *)[attachment attachmentCell] setImage:image];
	NSMutableAttributedString * aString = [[NSAttributedString attributedStringWithAttachment:attachment] mutableCopy];
	[image release];
	[attachment release];
	
	// add text to string and adjust vertical baseline of text so it aligns with icon
	[[aString mutableString] appendString:title];
	[aString addAttribute:NSBaselineOffsetAttributeName value:[NSNumber numberWithDouble:12.0] range:NSMakeRange(1, [title length])];

	return aString;
}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
	BOOL allow;
	if ( aTableView == race ) {
		allow = raceEnabled[rowIndex];
	} else {
		allow = roleEnabled[rowIndex];
	}
	return allow;
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	NSTableView * table = [aNotification object];
	if ( table == race ) {
		[self selectRace];
	} else {
		[self selectRole];
	}
}

- (IBAction)buttonSelect:(id)sender
{
	NSButtonCell * button = sender;
	if ( button == sexMale ) {
		[self selectGender:0];		
	} else if ( button == sexFemale ) {
		[self selectGender:1];
	} else if ( button == alignLawful ) {
		[self selectAlignment:0];
	} else if ( button = alignNeutral ) {
		[self selectAlignment:1];
	} else {
		[self selectAlignment:2];
	}
}

-(void)doAccept:(id)sender
{
	strcpy( plname, [[name stringValue] UTF8String] );
	[[self window] close];
}

-(void)doCancel:(id)sender
{
	[[self window] close];	
	[[NSApplication sharedApplication] terminate:self];
}


- (void)runModal
{
	[self selectInitialPlayer];
	[[NSApplication sharedApplication] runModalForWindow:[self window]];
}

-(void)windowWillClose:(NSNotification *)notification
{
	[[NSApplication sharedApplication] stopModal];
}


@end
