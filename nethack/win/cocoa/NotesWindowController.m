//
//  NotesWindowController.m
//  NetHackCocoa
//
//  Created by Bryce on 2/24/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "NotesWindowController.h"


@implementation NotesWindowController

-(void)awakeFromNib
{
	// load text
	NSString * text = [[NSUserDefaults standardUserDefaults] objectForKey:@"NotesWindowText"];
	if ( text ) {
		[textView setString:text];
	}
}

-(void)windowWillClose:(NSNotification *)notification
{
	NSString * text = [textView string];
	[[NSUserDefaults standardUserDefaults] setObject:text forKey:@"NotesWindowText"];	
}

@end
