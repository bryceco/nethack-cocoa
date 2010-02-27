//
//  StatsView.m
//  NetHackCocoa
//
//  Created by Bryce on 2/25/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "StatsView.h"

#import "hack.h"


@implementation StatsView


- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(void)clearAll
{
	NSString * clear = @"";
	[name setStringValue:clear];
	[role	setStringValue:clear];
	[dlvl	setStringValue:clear];
	[hp		setStringValue:clear];
	[pw		setStringValue:clear];
	[level	setStringValue:clear];
	[ac		setStringValue:clear];
	[xp		setStringValue:clear];
	[gold	setStringValue:clear];
	[str	setStringValue:clear];
	[iq		setStringValue:clear];
	[dex	setStringValue:clear];
	[wis	setStringValue:clear];
	[con	setStringValue:clear];
	[cha	setStringValue:clear];
	[turn	setStringValue:clear];
	[state	setStringValue:clear];
}

-(void)awakeFromNib
{
	[self clearAll];
}

-(BOOL)setItems:(NSString *)text
{
	NSCharacterSet * whitespace = [NSCharacterSet whitespaceCharacterSet];
	
	if ( [text rangeOfString:@"$:"].location != NSNotFound ) {
		
		// Dlvl:2 $:1977 HP:99(99) Pw:17(17) AC:-2 Xp:9/3619 T:7830
		NSScanner * scanner = [NSScanner scannerWithString:text];
		NSString * value = nil;
		int current, maximum;

		[scanner scanUpToString:@"$:" intoString:&value];
		[dlvl setStringValue:value];
		
		[scanner scanString:@"$:" intoString:NULL];
		[scanner scanUpToCharactersFromSet:whitespace intoString:&value];
		[gold setStringValue:value];
		
		[scanner scanString:@"HP:" intoString:NULL];
		[scanner scanUpToCharactersFromSet:whitespace intoString:&value];
		[hp setStringValue:value];
		sscanf( [value UTF8String], "%d(%d)", &current, &maximum );
		[hpMeter setMaxValue:maximum];
		[hpMeter setIntValue:current];
		[hpMeter setWarningValue:maximum  * 2/3.0];
		[hpMeter setCriticalValue:maximum * 1/3.0];
		 
		[scanner scanString:@"Pw:" intoString:NULL];
		[scanner scanUpToCharactersFromSet:whitespace intoString:&value];
		[pw setStringValue:value];
		sscanf( [value UTF8String], "%d(%d)", &current, &maximum );
		[pwMeter setMaxValue:maximum];
		[pwMeter setIntValue:current];
		[pwMeter setWarningValue:maximum  * 2/3.0];
		[pwMeter setCriticalValue:maximum * 1/3.0];
		
		[scanner scanString:@"AC:" intoString:NULL];
		[scanner scanUpToCharactersFromSet:whitespace intoString:&value];
		[ac setStringValue:value];
		
		if ( [scanner scanString:@"Xp:" intoString:&value] ) {
			// 10/9999
			[xpLabel setStringValue:value];
			[scanner scanUpToString:@"/" intoString:&value];
			[level setStringValue:value];
			[scanner scanString:@"/" intoString:NULL];
			[scanner scanUpToCharactersFromSet:whitespace intoString:&value];
			[xp setStringValue:value];
		} else if ( [scanner scanString:@"Exp:" intoString:&value] ) {
			[xpLabel setStringValue:value];
			[scanner scanUpToCharactersFromSet:whitespace intoString:&value];
			[level setStringValue:value];
			[xp setStringValue:@""];
		} else if ( [scanner scanString:@"HD:" intoString:&value] ) {
			// polymorphed HD
			[xpLabel setStringValue:value];
			[scanner scanUpToCharactersFromSet:whitespace intoString:&value];
			[xp setStringValue:value];
			[level setStringValue:@""];
		} else {
			assert(NO);
		}

		[scanner scanString:@"T:" intoString:NULL];
		[scanner scanUpToCharactersFromSet:whitespace intoString:&value];
		[turn setStringValue:value];
		
		value = [[scanner string] substringFromIndex:[scanner scanLocation]];
		value = [value stringByTrimmingCharactersInSet:whitespace];
		[state setStringValue:value];
				
	} else {

		// foo the bar St:18/02 Dx:18 Co:18 In:7 Ch:6 Neutral
		NSScanner * scanner = [NSScanner scannerWithString:text];
		NSString * value = nil;
		// foo the bar
		[scanner scanUpToString:@" St:" intoString:&value];
		[name setStringValue:value];
		
		[scanner scanString:@"St:" intoString:NULL];
		[scanner scanUpToCharactersFromSet:whitespace intoString:&value];
		[str setStringValue:value];
		
		[scanner scanString:@"Dx:" intoString:NULL];
		[scanner scanUpToCharactersFromSet:whitespace intoString:&value];
		[dex setStringValue:value];
		
		[scanner scanString:@"Co:" intoString:NULL];
		[scanner scanUpToCharactersFromSet:whitespace intoString:&value];
		[con setStringValue:value];
		
		[scanner scanString:@"In:" intoString:NULL];
		[scanner scanUpToCharactersFromSet:whitespace intoString:&value];
		[iq setStringValue:value];
		
		[scanner scanString:@"Wi:" intoString:NULL];
		[scanner scanUpToCharactersFromSet:whitespace intoString:&value];
		[wis setStringValue:value];
		
		[scanner scanString:@"Ch:" intoString:NULL];
		[scanner scanUpToCharactersFromSet:whitespace intoString:&value];
		[cha setStringValue:value];
		
		value = [[scanner string] substringFromIndex:[scanner scanLocation]];
		value = [value stringByTrimmingCharactersInSet:whitespace];
		value = [value stringByAppendingFormat:Upolyd?@" (%s) %s":@" %s %s", urace.adj, mons[u.umonnum].mname];
		[role setStringValue:value];
	}
	return YES;
}

@end
