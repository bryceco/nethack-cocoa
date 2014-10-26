/*
 *  wincocoa.h
 *  NetHackCocoa
 *
 *  Created by dirk on 6/26/09.
 *  Copyright 2010 Dirk Zimmermann. All rights reserved.
 *
 */

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

#include "hack.h"

extern FILE *cocoa_fopen(const char *filename, const char *mode);

void cocoa_init_nhwindows(int* argc, char** argv);
void cocoa_player_selection();
void cocoa_askname();
void cocoa_get_nh_event();
void cocoa_exit_nhwindows(const char *str);
void cocoa_suspend_nhwindows(const char *str);
void cocoa_resume_nhwindows();
winid cocoa_create_nhwindow(int type);
void cocoa_clear_nhwindow(winid wid);
void cocoa_display_nhwindow(winid wid, BOOLEAN_P block);
void cocoa_destroy_nhwindow(winid wid);
void cocoa_curs(winid wid, int x, int y);
void cocoa_putstr(winid wid, int attr, const char *text);
void cocoa_display_file(const char *filename, BOOLEAN_P must_exist);
void cocoa_start_menu(winid wid);
void cocoa_add_menu(winid wid, int glyph, const ANY_P *identifier,
					 CHAR_P accelerator, CHAR_P group_accel, int attr, 
					 const char *str, BOOLEAN_P presel);
void cocoa_end_menu(winid wid, const char *prompt);
int cocoa_select_menu(winid wid, int how, menu_item **menu_list);
void cocoa_update_inventory();
void cocoa_mark_synch();
void cocoa_wait_synch();
void cocoa_cliparound(int x, int y);
void cocoa_cliparound_window(winid wid, int x, int y);
void cocoa_print_glyph(winid wid, XCHAR_P x, XCHAR_P y, int glyph);
void cocoa_raw_print(const char *str);
void cocoa_raw_print_bold(const char *str);
int cocoa_nhgetch();
int cocoa_nh_poskey(int *x, int *y, int *mod);
void cocoa_nhbell();
int cocoa_doprev_message();
char cocoa_yn_function(const char *question, const char *choices, CHAR_P def);
void cocoa_getlin(const char *prompt, char *line);
int cocoa_get_ext_cmd();
void cocoa_number_pad(int num);
void cocoa_delay_output();
void cocoa_start_screen();
void cocoa_end_screen();
void cocoa_outrip(winid wid, int how);
void cocoa_preference_update(const char * pref);
void cocoa_prepare_for_exit();

coord CoordMake(xchar i, xchar j);

#ifdef __OBJC__

@class NhEventQueue;

@interface WinCocoa : NSObject {
}

+ (const char *)baseFilePath;
+ (void)expandFilename:(const char *)filename intoPath:(char *)path;
+ (int)keyWithKeyEvent:(NSEvent *)keyEvent;

@end

#endif