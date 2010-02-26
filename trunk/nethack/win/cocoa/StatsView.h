//
//  StatsView.h
//  NetHackCocoa
//
//  Created by Bryce on 2/25/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface StatsView : NSView {
	IBOutlet NSTextField		*	name;
	IBOutlet NSTextField		*	role;
	IBOutlet NSTextField		*	dlvl;
	IBOutlet NSTextField		*	hp;
	IBOutlet NSTextField		*	hd;
	IBOutlet NSTextField		*	pw;
	IBOutlet NSLevelIndicator	*	hpMeter;
	IBOutlet NSLevelIndicator	*	pwMeter;
	IBOutlet NSTextField		*	level;
	IBOutlet NSTextField		*	ac;
	IBOutlet NSTextField		*	xp;
	IBOutlet NSTextField		*	gold;
	IBOutlet NSTextField		*	str;
	IBOutlet NSTextField		*	iq;
	IBOutlet NSTextField		*	dex;
	IBOutlet NSTextField		*	wis;
	IBOutlet NSTextField		*	con;
	IBOutlet NSTextField		*	cha;
	IBOutlet NSTextField		*	turn;
	IBOutlet NSTextField		*	state;
}

-(BOOL)setItems:(NSString *)text;

@end
