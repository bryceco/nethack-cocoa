//
//  StatsView.h
//  NetHackCocoa
//
//  Created by Bryce on 2/25/10.
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


@interface StatsView : NSView {
	IBOutlet NSTextField		*	name;
	IBOutlet NSTextField		*	role;
	IBOutlet NSTextField		*	dlvl;
	IBOutlet NSTextField		*	xpLabel;
	IBOutlet NSTextField		*	xp;
	IBOutlet NSTextField		*	hp;
	IBOutlet NSTextField		*	pw;
	IBOutlet NSLevelIndicator	*	hpMeter;
	IBOutlet NSLevelIndicator	*	pwMeter;
	IBOutlet NSTextField		*	level;
	IBOutlet NSTextField		*	ac;
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
