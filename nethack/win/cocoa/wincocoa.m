/*
 *  wincocoa.m
 *  NetHackCocoa
 *
 *  Created by dirk on 6/26/09.
 *  Copyright 2010 Dirk Zimmermann. All rights reserved.
 *
 */

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

#include <stdio.h>
#include <fcntl.h>
#import <Carbon/Carbon.h>	// key codes

#include "dlb.h"
#include "hack.h"
#include "func_tab.h"

#import "wincocoa.h"
#import "NhWindow.h"
#import "NhMapWindow.h"
#import "MainWindowController.h"
#import "NhYnQuestion.h"
#import "NhEvent.h"
#import "NhEventQueue.h"
#import "NhItem.h"
#import "NhItemGroup.h"
#import "NhMenuWindow.h"
#import "NhStatusWindow.h"
#import "NSString+Z.h"
#import "NhTextInputEvent.h"

#ifdef __APPLE__
#include "TargetConditionals.h"
#endif

// mainly for tty port implementation
#define BASE_WINDOW ((winid) [NhWindow messageWindow])

#define kNetHackOptions (@"kNetHackOptions")

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

boolean cocoa_getpos = 0;

static char s_baseFilePath[FQN_MAX_FILENAME];

coord CoordMake(xchar i, xchar j) {
	coord c = {i,j};
	return c;
}

@implementation WinCocoa

+ (void)load {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	strcpy(s_baseFilePath, [[[NSBundle mainBundle] resourcePath] cStringUsingEncoding:NSASCIIStringEncoding]);

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
#if 0
	[defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
								@"role:samurai,gender:male,time,autopickup,showexp,pickup_types:$!?+\"=/,norest_on_space,runmode:walk,menu_tab_sep,tile_file:tiles40x20.bmp,tile_height:40,tile_width:20",
								kNetHackOptions,
								nil]];
#else
#endif
	NSString *netHackOptions = [defaults stringForKey:kNetHackOptions];
	if ( netHackOptions ) {
		setenv("NETHACKOPTIONS", [netHackOptions cStringUsingEncoding:NSASCIIStringEncoding], 1);
	}
	
	[pool release];
}

+ (const char *)baseFilePath {
	return s_baseFilePath;
}

+ (void)expandFilename:(const char *)filename intoPath:(char *)path {
	sprintf(path, "%s/%s", [self baseFilePath], filename);
}

+ (int)keyWithKeyEvent:(NSEvent *)keyEvent
{
	if ( [keyEvent type] != NSKeyDown )
		return 0;
		
	int key = 0;
	switch ( [keyEvent keyCode] ) {
			// arrows
		case kVK_LeftArrow:				key = 'h';				break;
		case kVK_RightArrow:			key	= 'l';				break;
		case kVK_DownArrow:				key = 'j';				break;
		case kVK_UpArrow:				key = 'k';				break;
			// keypad
		case kVK_ANSI_Keypad1:			key = 'b';				break;
		case kVK_ANSI_Keypad2:			key = 'j';				break;
		case kVK_ANSI_Keypad3:			key = 'n';				break;
		case kVK_ANSI_Keypad4:			key = 'h';				break;
		case kVK_ANSI_Keypad5:			key = '.';				break;
		case kVK_ANSI_Keypad6:			key = 'l';				break;
		case kVK_ANSI_Keypad7:			key = 'y';				break;
		case kVK_ANSI_Keypad8:			key = 'k';				break;
		case kVK_ANSI_Keypad9:			key = 'u';				break;
			// escape
		case kVK_Escape:				key = '\033';			break;
	}
	if ( key ) {
		NSUInteger modifier = [keyEvent modifierFlags];
		if ( modifier & NSShiftKeyMask ) {
			key = toupper(key);
		}
	} else {
		// "real" keys
		NSString * chars = [keyEvent charactersIgnoringModifiers];
		NSUInteger modifier = [keyEvent modifierFlags];
		key = [chars characterAtIndex:0];
		
		if ( modifier & NSCommandKeyMask ) {
			// map Cmd-x to Ctrl-x to match Qt port
			if ( strchr( "ad", key ) != NULL ) {
				modifier &= ~NSCommandKeyMask;
				modifier |= NSControlKeyMask;
			}
		}		
		
		if ( modifier & NSShiftKeyMask  ) {
			// system already upcases for us
		}
		if ( modifier & NSControlKeyMask ) {
			// convert to control key
			key = toupper(key) - 'A' + 1;
		}
		if ( modifier & NSAlternateKeyMask ) {
			// convert to meta key
			key = 0x80 | key;
		}
	}
	return key;
}

@end

FILE *cocoa_dlb_fopen(const char *filename, const char *mode) {
	char path[FQN_MAX_FILENAME];
	[WinCocoa expandFilename:filename intoPath:path];
	FILE *file = fopen(path, mode);
	return file;
}

// These must be defined but are not used (they handle keyboard interrupts).
void intron() {}
void introff() {}

int dosuspend() {
	NSLog(@"dosuspend");
	return 0;
}

void error(const char *s, ...) {
	//NSLog(@"error: %s");
	char message[512];
	va_list ap;
	va_start(ap, s);
	vsprintf(message, s, ap);
	va_end(ap);
	cocoa_raw_print(message);
	// todo (button to wait for user?)
	exit(0);
}

#pragma mark nethack window API

void cocoa_init_nhwindows(int* argc, char** argv) {
	//NSLog(@"init_nhwindows");
	iflags.runmode = RUN_STEP;
	iflags.window_inited = TRUE;
}

void cocoa_askname() {
	//NSLog(@"askname");
	cocoa_getlin("Enter your name", plname);
}

void cocoa_get_nh_event() {
	//NSLog(@"get_nh_event");
}

void cocoa_exit_nhwindows(const char *str) {
	NSLog(@"exit_nhwindows %s", str);
	// close all our windows so state gets saved cleanly
	[[MainWindowController instance] closeAllWindows];
}

void cocoa_suspend_nhwindows(const char *str) {
	NSLog(@"suspend_nhwindows %s", str);
}

void cocoa_resume_nhwindows() {
	NSLog(@"resume_nhwindows");
}

winid cocoa_create_nhwindow(int type) {
	NhWindow *w = nil;
	switch (type) {
		case NHW_MAP:
			w =  [NhWindow mapWindow];
			break;
		case NHW_STATUS:
			w = [NhWindow statusWindow];
			break;
		case NHW_MESSAGE:
			w = [NhWindow messageWindow];
			break;
		case NHW_MENU:
			w = [[NhMenuWindow alloc] initWithType:NHW_MENU];
			break;
		case NHW_TEXT:
			w = [[NhWindow alloc] initWithType:NHW_TEXT];
			break;
		default:
			assert(NO);
	}
	//NSLog(@"create_nhwindow(%x) %x", type, w);
	return (winid) w;
}

void cocoa_clear_nhwindow(winid wid) {
	//NSLog(@"clear_nhwindow %x", wid);
	[(NhWindow *) wid clear];
}

void cocoa_display_nhwindow(winid wid, BOOLEAN_P block) {
	//NSLog(@"display_nhwindow %x, %i, %i", wid, ((NhWindow *) wid).type, block);
	((NhWindow *) wid).blocking = block;
	[[MainWindowController instance] displayWindow:(NhWindow *) wid];
}

void cocoa_destroy_nhwindow(winid wid) {
	//NSLog(@"destroy_nhwindow %x", wid);
	NhWindow *w = (NhWindow *) wid;
	if (w != [NhWindow messageWindow] && w != [NhWindow statusWindow] && w != [NhWindow mapWindow]) {
		[w release];
	}
}

void cocoa_curs(winid wid, int x, int y) {
	//NSLog(@"curs %x %d,%d", wid, x, y);

	if (wid == WIN_MAP) {
		[(NhMapWindow *) wid setCursX:x y:y];
	}
}

void cocoa_putstr(winid wid, int attr, const char *text) {
	//NSLog(@"putstr %x %s", wid, text);
	if (wid == WIN_ERR || !wid) {
		wid = BASE_WINDOW;
	}
	// normal output to a window
	[(NhWindow *) wid print:text attr:attr];
	if (wid == WIN_MESSAGE || wid == BASE_WINDOW) {
		[[MainWindowController instance] refreshMessages];
	}		
}

void cocoa_display_file(const char *filename, BOOLEAN_P must_exist) {
	char tmp[ PATH_MAX ];
	[WinCocoa expandFilename:filename intoPath:tmp];

	NSString * text = [NSString stringWithContentsOfFile:[NSString stringWithUTF8String:filename] encoding:NSUTF8StringEncoding error:NULL];
	if ( text ) {
		[[MainWindowController instance] displayMessageWindow:text];
	} else {
		if ( must_exist ) {
			char msg[512];
			sprintf(msg, "Could not display file %s", filename);
			cocoa_raw_print(msg);
		}
	}
}

#pragma mark menu

void cocoa_start_menu(winid wid) {
	//NSLog(@"start_menu %x", wid);
	[(NhMenuWindow *) wid startMenu];
}

void cocoa_add_menu(winid wid, int glyph, const ANY_P *identifier,
					 CHAR_P accelerator, CHAR_P group_accel, int attr, 
					 const char *str, BOOLEAN_P presel) {
	//NSLog(@"add_menu %x %s", wid, str);
	NhMenuWindow *w = (NhMenuWindow *) wid;
	NSString *title = [NSString stringWithFormat:@"%s", str];
	if (identifier->a_void) {
		NhItem *i = [[NhItem alloc] initWithTitle:title
									   identifier:*identifier accelerator:accelerator glyph:glyph selected:presel];
		[w.currentItemGroup addItem:i];
		[i release];
	} else {
		NhItemGroup *g = [[NhItemGroup alloc] initWithTitle:title];
		[w addItemGroup:g];
		[g release];
	}
}

void cocoa_end_menu(winid wid, const char *prompt) {
	//NSLog(@"end_menu %x, %s", wid, prompt);
	if (prompt) {
		((NhMenuWindow *) wid).prompt = [NSString stringWithFormat:@"%s", prompt];
		//cocoa_putstr(WIN_MESSAGE, 0, prompt);
	} else {
		((NhMenuWindow *) wid).prompt = nil;
	}
}

int cocoa_select_menu(winid wid, int how, menu_item **selected) {
	//NSLog(@"select_menu %x", wid);
	NhMenuWindow *w = (NhMenuWindow *) wid;
	w.how = how;
	*selected = NULL;
	[[MainWindowController instance] showMenuWindow:w];
	
	if ( how != PICK_NONE ) {
		NhEvent *e = [[NhEventQueue instance] nextEvent];
		if (e.key > 0) {
			menu_item *pMenu = *selected = calloc(sizeof(menu_item), w.selected.count);
			for (NhItem *item in w.selected) {
				pMenu->count = item.amount;
				pMenu->item = item.identifier;
				pMenu++;
			}
			return w.selected.count;		
		} else {
			// cancelled
			return -1;
		}
	} else {
		return 0;
	}
}

void cocoa_update_inventory() {
	//NSLog(@"update_inventory");
	[[MainWindowController instance] updateInventory];
}

void cocoa_mark_synch() {
	//NSLog(@"mark_synch");
}

void cocoa_wait_synch() {
	NSLog(@"wait_synch");
//	[[MainViewController instance] refreshAllViews];
}

void cocoa_cliparound(int x, int y) {
	//NSLog(@"cliparound %d,%d", x, y);
	cocoa_cliparound_window(NHW_MAP, x, y);
}

void cocoa_cliparound_window(winid wid, int x, int y) {
	//	NSLog(@"cliparound_window %x %d,%d", wid, x, y);
	if (wid == NHW_MAP) {
		[[MainWindowController instance] clipAroundX:x y:y];
	}
}

void cocoa_print_glyph(winid wid, XCHAR_P x, XCHAR_P y, int glyph) {
	//NSLog(@"print_glyph %x %d,%d", wid, x, y);
	[(NhMapWindow *) wid printGlyph:glyph atX:x y:y];
}

void cocoa_raw_print(const char *str) {
	//NSLog(@"raw_print %s", str);
	cocoa_putstr((winid) [NhWindow messageWindow], 0, str);
}

void cocoa_raw_print_bold(const char *str) {
	//NSLog(@"raw_print_bold %s", str);
	cocoa_raw_print(str);
}

int cocoa_nhgetch() {
	NSLog(@"nhgetch");
	return 0;
}

int cocoa_nh_poskey(int *x, int *y, int *mod) {
	//NSLog(@"nh_poskey");
	[[MainWindowController instance] refreshAllViews];
	NhEvent *e = [[NhEventQueue instance] nextEvent];
	if (!e.isKeyEvent) {
		*x = e.x;
		*y = e.y;
		*mod = e.mod;
	}
	return e.key;
}

void cocoa_nhbell() {
	NSLog(@"nhbell");
}

int cocoa_doprev_message() {
	NSLog(@"doprev_message");
	return 0;
}

#pragma mark yn_function 

char cocoa_yn_function(const char *question, const char *choices, CHAR_P def) {
	//NSLog(@"yn_function %s", question);
	static const char * AlwaysYes[] = {
		"Really save?",
		"Overwrite the old file?",
		//		"Do you want to keep the save file?",
	};
	for ( int i = 0; i < sizeof AlwaysYes/sizeof AlwaysYes[0]; ++i ) {
		if ( !strcmp(AlwaysYes[i], question) ) {
			return 'y';
		}
	}
	
	NSString * text = [NSString stringWithFormat:@"%s", question];
	if ( choices && choices[0] ) {
		text = [text stringByAppendingFormat:@" [%s]", choices];
	}
	if ( def ) {
		text = [text stringByAppendingFormat:@" (%c)", def];
	}
	
	if ( [text containsString:@"direction"] ) {
		[[MainWindowController instance] showDirectionWithPrompt:text];
		NhEvent * e = [[NhEventQueue instance] nextEvent];
		return e.key;
	}
	
	if ( choices ) {
		if ( strcmp( choices, "yn" )==0 || strcmp( choices, "ynq" )==0 ) {
			NhYnQuestion * q = [[NhYnQuestion alloc] initWithQuestion:question choices:choices default:def];
			[[MainWindowController instance] showYnQuestion:q];
			NhEvent * e = [[NhEventQueue instance] nextEvent];
			[q release];
			return e.key;
		}
	}
	
	cocoa_putstr(WIN_MESSAGE, ATR_BOLD, [text UTF8String] );
	for (;;) {
		NhEvent *e = nil;
		e = [[NhEventQueue instance] nextEvent];
		if ( e.isKeyEvent ) {
			if ( choices == NULL || strchr( choices, e.key ) != NULL ) {
				return e.key;
			}
			if ( def && e.key == '\r' )
				return def;
		}
	}
}

void cocoa_getlin(const char *prompt, char *line) {
	//NSLog(@"getlin %s", prompt);
	cocoa_putstr(WIN_MESSAGE, 0, prompt);
	[[MainWindowController instance] refreshAllViews];
	[[MainWindowController instance] getLine];
	NhTextInputEvent *e = (NhTextInputEvent *) [[NhEventQueue instance] nextEvent];
	if ( [e class] == [NhTextInputEvent class]  &&  e.text ) {
		[e.text getCString:line maxLength:BUFSZ encoding:NSASCIIStringEncoding];
	} else {
		// cancel
		strcpy(line, "\033\000");
	}
}

int cocoa_get_ext_cmd() {
	//NSLog(@"get_ext_cmd");
	if ([[NhEventQueue instance] peek]) {
		// already have extended command in queue
	} else {
		// get command event
		[[MainWindowController instance] showExtendedCommands];
	}
	NhTextInputEvent *e = (NhTextInputEvent *) [[NhEventQueue instance] nextEvent];
	assert( [e class] == [NhTextInputEvent class] );
	const char * cmd = [e.text UTF8String];
		
	// return index of command, not its key
	for ( int i = 0; extcmdlist[i].ef_txt; ++i ) {
		if ( strcmp( extcmdlist[i].ef_txt, cmd ) == 0 ) {
			return i;
		}
	}
	return -1;
}

void cocoa_number_pad(int num) {
	//NSLog(@"number_pad %d", num);
}

void cocoa_delay_output() {
	//NSLog(@"delay_output");
	usleep(50000);
}

void cocoa_start_screen() {
	NSLog(@"start_screen");
}

void cocoa_end_screen() {
	NSLog(@"end_screen");
}

void cocoa_outrip(winid wid, int how) {
	NSLog(@"outrip %x", wid);
}

#pragma mark window API player_selection()

// from tty port
/* clean up and quit */
static void bail(const char *mesg) {
    cocoa_exit_nhwindows(mesg);
    terminate(EXIT_SUCCESS);
}

// from tty port
static int cocoa_role_select(char *pbuf, char *plbuf) {
	int i, n;
	char thisch, lastch = 0;
    char rolenamebuf[QBUFSZ];
	winid win;
	anything any;
	menu_item *selected = 0;
	
   	cocoa_clear_nhwindow(BASE_WINDOW);
	cocoa_putstr(BASE_WINDOW, 0, "Choosing Character's Role");
	
	/* Prompt for a role */
	win = create_nhwindow(NHW_MENU);
	start_menu(win);
	any.a_void = 0;         /* zero out all bits */
	for (i = 0; roles[i].name.m; i++) {
	    if (ok_role(i, flags.initrace, flags.initgend,
					flags.initalign)) {
			any.a_int = i+1;	/* must be non-zero */
			thisch = lowc(roles[i].name.m[0]);
			if (thisch == lastch) thisch = highc(thisch);
			if (flags.initgend != ROLE_NONE && flags.initgend != ROLE_RANDOM) {
				if (flags.initgend == 1  && roles[i].name.f)
					Strcpy(rolenamebuf, roles[i].name.f);
				else
					Strcpy(rolenamebuf, roles[i].name.m);
			} else {
				if (roles[i].name.f) {
					Strcpy(rolenamebuf, roles[i].name.m);
					Strcat(rolenamebuf, "/");
					Strcat(rolenamebuf, roles[i].name.f);
				} else 
					Strcpy(rolenamebuf, roles[i].name.m);
			}	
			add_menu(win, NO_GLYPH, &any, thisch,
					 0, ATR_NONE, an(rolenamebuf), MENU_UNSELECTED);
			lastch = thisch;
	    }
	}
	any.a_int = pick_role(flags.initrace, flags.initgend,
						  flags.initalign, PICK_RANDOM)+1;
	if (any.a_int == 0)	/* must be non-zero */
	    any.a_int = randrole()+1;
		add_menu(win, NO_GLYPH, &any , '*', 0, ATR_NONE,
				 "Random", MENU_UNSELECTED);
		any.a_int = i+1;	/* must be non-zero */
		add_menu(win, NO_GLYPH, &any , 'q', 0, ATR_NONE,
				 "Quit", MENU_UNSELECTED);
		Sprintf(pbuf, "Pick a role for your %s", plbuf);
		end_menu(win, pbuf);
		n = select_menu(win, PICK_ONE, &selected);
		cocoa_destroy_nhwindow(win);
		
	/* Process the choice */
		if (n != 1 || selected[0].item.a_int == any.a_int) {
			free((genericptr_t) selected),	selected = 0;	
			return (-1);		/* Selected quit */
		}
	
	flags.initrole = selected[0].item.a_int - 1;
	free((genericptr_t) selected),	selected = 0;
	return (flags.initrole);
}

// from tty port
static int cocoa_race_select(char * pbuf, char * plbuf) {
	int i, k, n;
	char thisch, lastch = -1;
	winid win;
	anything any;
	menu_item *selected = 0;
	
	/* Count the number of valid races */
	n = 0;	/* number valid */
	k = 0;	/* valid race */
	for (i = 0; races[i].noun; i++) {
	    if (ok_race(flags.initrole, i, flags.initgend,
					flags.initalign)) {
			n++;
			k = i;
	    }
	}
	if (n == 0) {
	    for (i = 0; races[i].noun; i++) {
			if (validrace(flags.initrole, i)) {
				n++;
				k = i;
			}
	    }
	}
	
	/* Permit the user to pick, if there is more than one */
	if (n > 1) {
	    cocoa_clear_nhwindow(BASE_WINDOW);
	    cocoa_putstr(BASE_WINDOW, 0, "Choosing Race");
	    win = create_nhwindow(NHW_MENU);
	    start_menu(win);
	    any.a_void = 0;         /* zero out all bits */
	    for (i = 0; races[i].noun; i++)
			if (ok_race(flags.initrole, i, flags.initgend,
						flags.initalign)) {
				any.a_int = i+1;	/* must be non-zero */
				thisch = lowc(races[i].noun[0]);
				if (thisch == lastch) thisch = highc(thisch);
				add_menu(win, NO_GLYPH, &any, thisch,
						 0, ATR_NONE, races[i].noun, MENU_UNSELECTED);
				lastch = thisch;
			}
	    any.a_int = pick_race(flags.initrole, flags.initgend,
							  flags.initalign, PICK_RANDOM)+1;
	    if (any.a_int == 0)	/* must be non-zero */
			any.a_int = randrace(flags.initrole)+1;
	    add_menu(win, NO_GLYPH, &any , '*', 0, ATR_NONE,
				 "Random", MENU_UNSELECTED);
	    any.a_int = i+1;	/* must be non-zero */
	    add_menu(win, NO_GLYPH, &any , 'q', 0, ATR_NONE,
				 "Quit", MENU_UNSELECTED);
	    Sprintf(pbuf, "Pick the race of your %s", plbuf);
	    end_menu(win, pbuf);
	    n = select_menu(win, PICK_ONE, &selected);
	    destroy_nhwindow(win);
	    if (n != 1 || selected[0].item.a_int == any.a_int)
			return(-1);		/* Selected quit */
		
	    k = selected[0].item.a_int - 1;
	    free((genericptr_t) selected),	selected = 0;
	}
	
	flags.initrace = k;
	return (k);
}

// from tty port
void cocoa_player_selection() {
#if 1
	[[MainWindowController instance] showPlayerSelection];
#else
	int i, k, n;
	char pick4u = 'n';
	char pbuf[QBUFSZ], plbuf[QBUFSZ];
	winid win;
	anything any;
	menu_item *selected = 0;
	
	/* prevent an unnecessary prompt */
	rigid_role_checks();
	
	/* Should we randomly pick for the player? */
	if (!flags.randomall &&
	    (flags.initrole == ROLE_NONE || flags.initrace == ROLE_NONE ||
	     flags.initgend == ROLE_NONE || flags.initalign == ROLE_NONE)) {
			char *prompt = build_plselection_prompt(pbuf, QBUFSZ, flags.initrole,
													flags.initrace, flags.initgend, flags.initalign);
			
			pick4u = cocoa_yn_function(prompt, "ynq", pick4u);
			cocoa_clear_nhwindow(BASE_WINDOW);
			
			if (pick4u != 'y' && pick4u != 'n') {
			give_up:	/* Quit */
				if (selected) free((genericptr_t) selected);
				bail((char *)0);
				/*NOTREACHED*/
				return;
			}
		}
	
	(void)  root_plselection_prompt(plbuf, QBUFSZ - 1,
									flags.initrole, flags.initrace, flags.initgend, flags.initalign);
	
	/* Select a role, if necessary */
	/* we'll try to be compatible with pre-selected race/gender/alignment,
	 * but may not succeed */
	if (flags.initrole < 0) {
	    /* Process the choice */
	    if (pick4u == 'y' || flags.initrole == ROLE_RANDOM || flags.randomall) {
			/* Pick a random role */
			flags.initrole = pick_role(flags.initrace, flags.initgend,
									   flags.initalign, PICK_RANDOM);
			if (flags.initrole < 0) {
				cocoa_putstr(BASE_WINDOW, 0, "Incompatible role!");
				flags.initrole = randrole();
			}
	    } else {
	    	if (cocoa_role_select(pbuf, plbuf) < 0) goto give_up;
	    }
	    (void)  root_plselection_prompt(plbuf, QBUFSZ - 1,
										flags.initrole, flags.initrace, flags.initgend, flags.initalign);
	}
	
	/* Select a race, if necessary */
	/* force compatibility with role, try for compatibility with
	 * pre-selected gender/alignment */
	if (flags.initrace < 0 || !validrace(flags.initrole, flags.initrace)) {
	    /* pre-selected race not valid */
	    if (pick4u == 'y' || flags.initrace == ROLE_RANDOM || flags.randomall) {
			flags.initrace = pick_race(flags.initrole, flags.initgend,
									   flags.initalign, PICK_RANDOM);
			if (flags.initrace < 0) {
				cocoa_putstr(BASE_WINDOW, 0, "Incompatible race!");
				flags.initrace = randrace(flags.initrole);
			}
	    } else {	/* pick4u == 'n' */
	    	if (cocoa_race_select(pbuf, plbuf) < 0) goto give_up;
	    }
	    (void)  root_plselection_prompt(plbuf, QBUFSZ - 1,
										flags.initrole, flags.initrace, flags.initgend, flags.initalign);
	}
	
	/* Select a gender, if necessary */
	/* force compatibility with role/race, try for compatibility with
	 * pre-selected alignment */
	if (flags.initgend < 0 || !validgend(flags.initrole, flags.initrace,
										 flags.initgend)) {
		/* pre-selected gender not valid */
		if (pick4u == 'y' || flags.initgend == ROLE_RANDOM || flags.randomall) {
			flags.initgend = pick_gend(flags.initrole, flags.initrace,
									   flags.initalign, PICK_RANDOM);
			if (flags.initgend < 0) {
				cocoa_putstr(BASE_WINDOW, 0, "Incompatible gender!");
				flags.initgend = randgend(flags.initrole, flags.initrace);
			}
		} else {	/* pick4u == 'n' */
			/* Count the number of valid genders */
			n = 0;	/* number valid */
			k = 0;	/* valid gender */
			for (i = 0; i < ROLE_GENDERS; i++) {
				if (ok_gend(flags.initrole, flags.initrace, i,
							flags.initalign)) {
					n++;
					k = i;
				}
			}
			if (n == 0) {
				for (i = 0; i < ROLE_GENDERS; i++) {
					if (validgend(flags.initrole, flags.initrace, i)) {
						n++;
						k = i;
					}
				}
			}
			
			/* Permit the user to pick, if there is more than one */
			if (n > 1) {
				cocoa_clear_nhwindow(BASE_WINDOW);
				cocoa_putstr(BASE_WINDOW, 0, "Choosing Gender");
				win = create_nhwindow(NHW_MENU);
				start_menu(win);
				any.a_void = 0;         /* zero out all bits */
				for (i = 0; i < ROLE_GENDERS; i++)
					if (ok_gend(flags.initrole, flags.initrace, i,
								flags.initalign)) {
						any.a_int = i+1;
						add_menu(win, NO_GLYPH, &any, genders[i].adj[0],
								 0, ATR_NONE, genders[i].adj, MENU_UNSELECTED);
					}
				any.a_int = pick_gend(flags.initrole, flags.initrace,
									  flags.initalign, PICK_RANDOM)+1;
				if (any.a_int == 0)	/* must be non-zero */
					any.a_int = randgend(flags.initrole, flags.initrace)+1;
				add_menu(win, NO_GLYPH, &any , '*', 0, ATR_NONE,
						 "Random", MENU_UNSELECTED);
				any.a_int = i+1;	/* must be non-zero */
				add_menu(win, NO_GLYPH, &any , 'q', 0, ATR_NONE,
						 "Quit", MENU_UNSELECTED);
				Sprintf(pbuf, "Pick the gender of your %s", plbuf);
				end_menu(win, pbuf);
				n = select_menu(win, PICK_ONE, &selected);
				destroy_nhwindow(win);
				if (n != 1 || selected[0].item.a_int == any.a_int)
					goto give_up;		/* Selected quit */
				
				k = selected[0].item.a_int - 1;
				free((genericptr_t) selected),	selected = 0;
			}
			flags.initgend = k;
		}
	    (void)  root_plselection_prompt(plbuf, QBUFSZ - 1,
										flags.initrole, flags.initrace, flags.initgend, flags.initalign);
	}
	
	/* Select an alignment, if necessary */
	/* force compatibility with role/race/gender */
	if (flags.initalign < 0 || !validalign(flags.initrole, flags.initrace,
										   flags.initalign)) {
	    /* pre-selected alignment not valid */
	    if (pick4u == 'y' || flags.initalign == ROLE_RANDOM || flags.randomall) {
			flags.initalign = pick_align(flags.initrole, flags.initrace,
										 flags.initgend, PICK_RANDOM);
			if (flags.initalign < 0) {
				cocoa_putstr(BASE_WINDOW, 0, "Incompatible alignment!");
				flags.initalign = randalign(flags.initrole, flags.initrace);
			}
	    } else {	/* pick4u == 'n' */
			/* Count the number of valid alignments */
			n = 0;	/* number valid */
			k = 0;	/* valid alignment */
			for (i = 0; i < ROLE_ALIGNS; i++) {
				if (ok_align(flags.initrole, flags.initrace, flags.initgend,
							 i)) {
					n++;
					k = i;
				}
			}
			if (n == 0) {
				for (i = 0; i < ROLE_ALIGNS; i++) {
					if (validalign(flags.initrole, flags.initrace, i)) {
						n++;
						k = i;
					}
				}
			}
			
			/* Permit the user to pick, if there is more than one */
			if (n > 1) {
				cocoa_clear_nhwindow(BASE_WINDOW);
				cocoa_putstr(BASE_WINDOW, 0, "Choosing Alignment");
				win = create_nhwindow(NHW_MENU);
				start_menu(win);
				any.a_void = 0;         /* zero out all bits */
				for (i = 0; i < ROLE_ALIGNS; i++)
					if (ok_align(flags.initrole, flags.initrace,
								 flags.initgend, i)) {
						any.a_int = i+1;
						add_menu(win, NO_GLYPH, &any, aligns[i].adj[0],
								 0, ATR_NONE, aligns[i].adj, MENU_UNSELECTED);
					}
				any.a_int = pick_align(flags.initrole, flags.initrace,
									   flags.initgend, PICK_RANDOM)+1;
				if (any.a_int == 0)	/* must be non-zero */
					any.a_int = randalign(flags.initrole, flags.initrace)+1;
				add_menu(win, NO_GLYPH, &any , '*', 0, ATR_NONE,
						 "Random", MENU_UNSELECTED);
				any.a_int = i+1;	/* must be non-zero */
				add_menu(win, NO_GLYPH, &any , 'q', 0, ATR_NONE,
						 "Quit", MENU_UNSELECTED);
				Sprintf(pbuf, "Pick the alignment of your %s", plbuf);
				end_menu(win, pbuf);
				n = select_menu(win, PICK_ONE, &selected);
				destroy_nhwindow(win);
				if (n != 1 || selected[0].item.a_int == any.a_int)
					goto give_up;		/* Selected quit */
				
				k = selected[0].item.a_int - 1;
				free((genericptr_t) selected),	selected = 0;
			}
			flags.initalign = k;
	    }
	}
	/* Success! */
	cocoa_display_nhwindow(BASE_WINDOW, FALSE);
#endif
}
