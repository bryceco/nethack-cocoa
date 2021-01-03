/*
 *  Inventory.c
 *  NetHackCocoa
 *
 *  Created by Bryce on 2/24/10.
 *  Copyright 2010 Bryce Cogswell. All rights reserved.
 * Copyright (c) Stichting Mathematisch Centrum, Amsterdam, 1985.
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
#include "Inventory.h"


void InventoryOfTile( int xPos, int yPos, char out_str[] )
{
	coord	cc = { xPos, yPos };

	out_str[0] = 0;
	const char *firstmatch = NULL;
	struct permonst *for_supplement = NULL;
	char dmpbuf[BUFSZ];
	if ( do_screen_description(cc, TRUE, 0, dmpbuf, &firstmatch, &for_supplement) ) {
		(void) decode_mixed(out_str, dmpbuf);
	} else {
		strcpy( out_str, "I've never heard of such things." );
	}
}


