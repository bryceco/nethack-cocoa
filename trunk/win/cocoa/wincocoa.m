/*
 *  wincocoa.c
 *  nethack-cocoa
 *
 *  Created by dirk on 7/21/09.
 *  Copyright 2009 Dirk Zimmermann. All rights reserved.
 *
 */

//  This file is part of nethack-cocoa.
//
//  nethack-cocoa is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  nethack-cocoa is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with nethack-cocoa.  If not, see <http://www.gnu.org/licenses/>.

#import "wincocoa.h"
#import "NethackWindow.h"
#import "WindowManager.h"
#import "MainController.h"

#include <stdio.h>
#include "dlb.h"

#undef DEFAULT_WINDOW_SYS
#define DEFAULT_WINDOW_SYS "cocoa"

struct window_procs cocoa_procs = {
"cocoa",
WC_COLOR|WC_HILITE_PET|
WC_ASCII_MAP|WC_TILED_MAP|
WC_FONT_MAP|WC_TILE_FILE|WC_TILE_WIDTH|WC_TILE_HEIGHT|
WC_PLAYER_SELECTION|WC_SPLASH_SCREEN,
0L,
cocoa_init_nhwindows,
cocoa_player_selection,
cocoa_askname,
cocoa_get_nh_event,
cocoa_exit_nhwindows,
cocoa_suspend_nhwindows,
cocoa_resume_nhwindows,
cocoa_create_nhwindow,
cocoa_clear_nhwindow,
cocoa_display_nhwindow,
cocoa_destroy_nhwindow,
cocoa_curs,
cocoa_putstr,
cocoa_display_file,
cocoa_start_menu,
cocoa_add_menu,
cocoa_end_menu,
cocoa_select_menu,
genl_message_menu,	  /* no need for X-specific handling */
cocoa_update_inventory,
cocoa_mark_synch,
cocoa_wait_synch,
#ifdef CLIPPING
cocoa_cliparound,
#endif
#ifdef POSITIONBAR
donull,
#endif
cocoa_print_glyph,
cocoa_raw_print,
cocoa_raw_print_bold,
cocoa_nhgetch,
cocoa_nh_poskey,
cocoa_nhbell,
cocoa_doprev_message,
cocoa_yn_function,
cocoa_getlin,
cocoa_get_ext_cmd,
cocoa_number_pad,
cocoa_delay_output,
#ifdef CHANGE_COLOR	 /* only a Mac option currently */
donull,
donull,
#endif
/* other defs that really should go away (they're tty specific) */
cocoa_start_screen,
cocoa_end_screen,
cocoa_outrip,
genl_preference_update,
};

void process_options(int argc, char *argv[]) {
	iflags.use_color = TRUE;
}

FILE *cocoa_fopen(const char *filename, const char *mode) {
	NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithCString:filename] ofType:@""];
	const char *pathc = [path cStringUsingEncoding:NSStringEncodingConversionAllowLossy];
	FILE *file = fopen(pathc, mode);
	return file;
}

void intron() {
	NSLog(@"intron");
}

void introff() {
	NSLog(@"introff");
}

int dosuspend() {
	NSLog(@"dosuspend");
	return 0;
}

int dosh() {
	NSLog(@"dosh");
	return 0;
}

void error(const char *s, ...) {
	// todo
	NSLog(@"error: %s");
	exit(0);
}

void regularize(char *s) {
	NSLog(@"regularize %s", s);
}

int child(int wt) {
	NSLog(@"child %d", wt);
	return 0;
}

#pragma mark nethack window system API

void cocoa_init_nhwindows(int* argc, char** argv) {
	iflags.window_inited = TRUE;
}

void cocoa_player_selection() {
	strcpy(pl_character, "Val");
	pl_race = 2;
}

void cocoa_askname() {
	// todo
	NSString *name = @"Dirk";
	[name getCString:plname maxLength:PL_NSIZ encoding:NSASCIIStringEncoding];
}

void cocoa_get_nh_event() {
	NSLog(@"cocoa_get_nh_event");
}

void cocoa_exit_nhwindows(const char *str) {
	NSLog(@"cocoa_exit_nhwindows %s", str);
	[[MainController instance] waitForUser];
}

void cocoa_suspend_nhwindows(const char *str) {
	NSLog(@"cocoa_suspend_nhwindows %s", str);
}

void cocoa_resume_nhwindows() {
	NSLog(@"cocoa_resume_nhwindows");
}

winid cocoa_create_nhwindow(int type) {
	return [[WindowManager instance] createWindowWithType:type];
}

void cocoa_clear_nhwindow(winid wid) {
	//NSLog(@"cocoa_clear_nhwindow %d", wid);
	NethackWindow *w = [[WindowManager instance] windowWithId:wid];
	[w clear];
}

void cocoa_display_nhwindow(winid wid, BOOLEAN_P block) {
	// todo
	NSLog(@"cocoa_display_nhwindow %d", wid);
	NethackWindow *w = [[WindowManager instance] windowWithId:wid];
	[w display];
}

void cocoa_destroy_nhwindow(winid wid) {
	// todo
	//NSLog(@"cocoa_destroy_nhwindow %d", wid);
}

void cocoa_curs(winid wid, int x, int y) {
	//NSLog(@"cocoa_curs %d %d,%d", wid, x, y);
}

void cocoa_putstr(winid wid, int attr, const char *text) {
	// todo
	NSLog(@"cocoa_putstr %d %s", wid, text);
	NethackWindow *w = [[WindowManager instance] windowWithId:wid];
	NSString *s = [NSString stringWithCString:text];
	[w putString:s];
}

void cocoa_display_file(const char *filename, BOOLEAN_P must_exist) {
	// todo
	//NSLog(@"cocoa_display_file %s", filename);
}

void cocoa_start_menu(winid wid) {
	// todo
	//NSLog(@"cocoa_start_menu %d", wid);
}

void cocoa_add_menu(winid wid, int glyph, const ANY_P *identifier,
					 CHAR_P accelerator, CHAR_P group_accel, int attr, 
					 const char *str, BOOLEAN_P presel) {
	// todo
	//NSLog(@"cocoa_add_menu %d %s", wid, str);
}

void cocoa_end_menu(winid wid, const char *prompt) {
	// todo
	//NSLog(@"cocoa_end_menu %d, %s", wid, prompt);
}

int cocoa_select_menu(winid wid, int how, menu_item **menu_list) {
	// todo
	NSLog(@"cocoa_select_menu %x", wid);
	return 0;
}

void cocoa_update_inventory() {
	//NSLog(@"cocoa_update_inventory");
}

void cocoa_mark_synch() {
	//NSLog(@"cocoa_mark_synch");
}

void cocoa_wait_synch() {
	//NSLog(@"cocoa_wait_synch");
}

void cocoa_cliparound(int x, int y) {
	//NSLog(@"cocoa_cliparound %d,%d", x, y);
	[[WindowManager instance] setClipX:x];
	[[WindowManager instance] setClipY:y];
}

void cocoa_cliparound_window(winid wid, int x, int y) {
	NSLog(@"cocoa_cliparound_window %d %d,%d", wid, x, y);
}

void cocoa_print_glyph(winid wid, XCHAR_P x, XCHAR_P y, int glyph) {
	//NSLog(@"cocoa_print_glyph %d %d,%d", wid, x, y);
	[[[WindowManager instance] windowWithId:wid] setGlyph:glyph atX:x y:y];
}

void cocoa_raw_print(const char *str) {
	NSLog(@"cocoa_raw_print %s", str);
}

void cocoa_raw_print_bold(const char *str) {
	NSLog(@"cocoa_raw_print_bold %s", str);
}

int cocoa_nhgetch() {
	NSLog(@"cocoa_nhgetch");
	return 0;
}

int cocoa_nh_poskey(int *x, int *y, int *mod) {
	NSLog(@"cocoa_nh_poskey");
	// todo
	[[MainController instance] waitForUser];
	return 0;
}

void cocoa_nhbell() {}

int cocoa_doprev_message() {
	NSLog(@"cocoa_doprev_message");
	return 0;
}

char cocoa_yn_function(const char *question, const char *choices, CHAR_P def) {
	// todo
	NSLog(@"cocoa_yn_function %s", question);
	return 0;
}

void cocoa_getlin(const char *prompt, char *line) {
	// todo
	NSLog(@"cocoa_getlin %s", prompt);
}

int cocoa_get_ext_cmd() {
	// todo
	return 0;
}

void cocoa_number_pad(int num) {
	NSLog(@"cocoa_number_pad %d", num);
}

void cocoa_delay_output() {
	NSLog(@"cocoa_delay_output");
}

void cocoa_start_screen() {
	NSLog(@"cocoa_start_screen");
}

void cocoa_end_screen() {
	NSLog(@"cocoa_end_screen");
}

void cocoa_outrip(winid wid, int how) {
	NSLog(@"cocoa_outrip %d", wid);
}

void cocoa_main() {
	int argc = 0;
	char **argv = NULL;
	
	// create save directory
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *saveDirectory = [paths lastObject];
	saveDirectory = [saveDirectory stringByAppendingPathComponent:@"nethack"];
	NSString *currentDirectory = [NSString stringWithString:saveDirectory];
	saveDirectory = [saveDirectory stringByAppendingPathComponent:@"save"];
	NSLog(@"saveDirectory %@", saveDirectory);
	if (![[NSFileManager defaultManager] fileExistsAtPath:saveDirectory]) {
		BOOL succ = [[NSFileManager defaultManager] createDirectoryAtPath:saveDirectory withIntermediateDirectories:YES
															   attributes:nil error:nil];
		if (!succ) {
			NSLog(@"saveDirectory could not be created!");
		}
	}
	[[NSFileManager defaultManager] changeCurrentDirectoryPath:currentDirectory];
	NSArray *filelist = [[NSFileManager defaultManager] directoryContentsAtPath:saveDirectory];
	for (NSString *filename in filelist) {
		NSLog(@"file %@", filename);
	}
	
	choose_windows(DEFAULT_WINDOW_SYS); /* choose a default window system */
	initoptions();			   /* read the resource file */
	
	init_nhwindows(&argc, argv);		   /* initialize the window system */
	process_options(argc, argv);	   /* process command line options or equiv */
	
	dlb_init();
	vision_init();
	display_gamewindows();		   /* create & display the game windows */
	
	register int fd;
	if ((fd = restore_saved_game()) >= 0) {
#ifdef WIZARD
		/* Since wizard is actually flags.debug, restoring might
		 * overwrite it.
		 */
		boolean remember_wiz_mode = wizard;
#endif
		const char *fq_save = fqname(SAVEF, SAVEPREFIX, 1);
		
		//(void) chmod(fq_save,0);	/* disallow parallel restores */
		(void) signal(SIGINT, (SIG_RET_TYPE) done1);
#ifdef NEWS
		if(iflags.news) {
		    display_file(NEWS, FALSE);
		    iflags.news = FALSE; /* in case dorecover() fails */
		}
#endif
		pline("Restoring save file...");
		mark_synch();	/* flush output */
		if(!dorecover(fd))
			goto not_recovered;
#ifdef WIZARD
		if(!wizard && remember_wiz_mode) wizard = TRUE;
#endif
		check_special_room(FALSE);
		//wd_message();
		
		if (discover || wizard) {
			if(yn("Do you want to keep the save file?") == 'n') {
				// todo allows cheating but also saves from crashes
			    //(void) delete_savefile();
			}
			else {
			    //(void) chmod(fq_save,FCMASK); /* back to readable */
			    compress(fq_save);
			}
		}
		flags.move = 0;
	} else {
	not_recovered:
		player_selection();
		newgame();
		//wd_message();
		
		flags.move = 0;
		set_wear();
		(void) pickup(1);
	}
	
	moveloop();
	exit(EXIT_SUCCESS);
}