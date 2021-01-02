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

char monsyms[ 3 ];

static int append_str(char * buf, const char * new_str)
{
    int space_left;	/* space remaining in buf */
	
    if (strstri(buf, new_str)) return 0;
	
    space_left = BUFSZ - strlen(buf) - 1;
    (void) strncat(buf, " or ", space_left);
    (void) strncat(buf, new_str, space_left - 4);
    return 1;
}

/* Returns "true" for characters that could represent a monster's stomach. */
static boolean is_swallow_sym(int c)
{
    int i;
    for (i = S_sw_tl; i <= S_sw_br; i++)
		if ((int)showsyms[i] == c) return TRUE;
    return FALSE;
}


/*
 * Return the name of the glyph found at (x,y).
 * If not hallucinating and the glyph is a monster, also monster data.
 */
static struct permonst * lookat(int x, int y, char * buf, char * monbuf)
{
    register struct monst *mtmp = (struct monst *) 0;
    struct permonst *pm = (struct permonst *) 0;
    int glyph;
	
    buf[0] = monbuf[0] = 0;
    glyph = glyph_at(x,y);
    if (u.ux == x && u.uy == y && senseself()) {
		char race[QBUFSZ];
		
		/* if not polymorphed, show both the role and the race */
		race[0] = 0;
		if (!Upolyd) {
			Sprintf(race, "%s ", urace.adj);
		}
		
		Sprintf(buf, "%s%s%s called %s",
				Invis ? "invisible " : "",
				race,
				mons[u.umonnum].mname,
				plname);
		/* file lookup can't distinguish between "gnomish wizard" monster
		 and correspondingly named player character, always picking the
		 former; force it to find the general "wizard" entry instead */
		if (Role_if(PM_WIZARD) && Race_if(PM_GNOME) && !Upolyd)
			pm = &mons[PM_WIZARD];
		
#ifdef STEED
		if (u.usteed) {
			char steedbuf[BUFSZ];
			
			Sprintf(steedbuf, ", mounted on %s", y_monnam(u.usteed));
			/* assert((sizeof buf >= strlen(buf)+strlen(steedbuf)+1); */
			Strcat(buf, steedbuf);
		}
#endif
		/* When you see yourself normally, no explanation is appended
		 (even if you could also see yourself via other means).
		 Sensing self while blind or swallowed is treated as if it
		 were by normal vision (cf canseeself()). */
		if ((Invisible || u.uundetected) && !Blind && !u.uswallow) {
			unsigned how = 0;
			
			if (Infravision)	 how |= 1;
			if (Unblind_telepat) how |= 2;
			if (Detect_monsters) how |= 4;
			
			if (how)
				Sprintf(eos(buf), " [seen: %s%s%s%s%s]",
						(how & 1) ? "infravision" : "",
						/* add comma if telep and infrav */
						((how & 3) > 2) ? ", " : "",
						(how & 2) ? "telepathy" : "",
						/* add comma if detect and (infrav or telep or both) */
						((how & 7) > 4) ? ", " : "",
						(how & 4) ? "monster detection" : "");
		}
    } else if (u.uswallow) {
		/* all locations when swallowed other than the hero are the monster */
		Sprintf(buf, "interior of %s",
				Blind ? "a monster" : a_monnam(u.ustuck));
		pm = u.ustuck->data;
    } else if (glyph_is_monster(glyph)) {
		bhitpos.x = x;
		bhitpos.y = y;
		mtmp = m_at(x,y);
		if (mtmp != (struct monst *) 0) {
			char *name, monnambuf[BUFSZ];
			boolean accurate = !Hallucination;
			
			if (mtmp->data == &mons[PM_COYOTE] && accurate)
				name = coyotename(mtmp, monnambuf);
			else
				name = distant_monnam(mtmp, ARTICLE_NONE, monnambuf);
			
			pm = mtmp->data;
			Sprintf(buf, "%s%s%s",
					(mtmp->mx != x || mtmp->my != y) ?
					((mtmp->isshk && accurate)
					 ? "tail of " : "tail of a ") : "",
					(mtmp->mtame && accurate) ? "tame " :
					(mtmp->mpeaceful && accurate) ? "peaceful " : "",
					name);
			if (u.ustuck == mtmp)
				Strcat(buf, (Upolyd && sticks(youmonst.data)) ?
					   ", being held" : ", holding you");
			if (mtmp->mleashed)
				Strcat(buf, ", leashed to you");
			
			if (mtmp->mtrapped && cansee(mtmp->mx, mtmp->my)) {
				struct trap *t = t_at(mtmp->mx, mtmp->my);
				int tt = t ? t->ttyp : NO_TRAP;
				
				/* newsym lets you know of the trap, so mention it here */
				if (tt == BEAR_TRAP || tt == PIT ||
					tt == SPIKED_PIT || tt == WEB)
					Sprintf(eos(buf), ", trapped in %s",
							an(defsyms[trap_to_defsym(tt)].explanation));
			}
			
			{
				int ways_seen = 0, normal = 0, xraydist;
				boolean useemon = (boolean) canseemon(mtmp);
				
				xraydist = (u.xray_range<0) ? -1 : u.xray_range * u.xray_range;
				/* normal vision */
				if ((mtmp->wormno ? worm_known(mtmp) : cansee(mtmp->mx, mtmp->my)) &&
					mon_visible(mtmp) && !mtmp->minvis) {
					ways_seen++;
					normal++;
				}
				/* see invisible */
				if (useemon && mtmp->minvis)
					ways_seen++;
				/* infravision */
				if ((!mtmp->minvis || See_invisible) && see_with_infrared(mtmp))
					ways_seen++;
				/* telepathy */
				if (tp_sensemon(mtmp))
					ways_seen++;
				/* xray */
				if (useemon && xraydist > 0 &&
					distu(mtmp->mx, mtmp->my) <= xraydist)
					ways_seen++;
				if (Detect_monsters)
					ways_seen++;
				if (MATCH_WARN_OF_MON(mtmp))
					ways_seen++;
				
				if (ways_seen > 1 || !normal) {
					if (normal) {
						Strcat(monbuf, "normal vision");
						/* can't actually be 1 yet here */
						if (ways_seen-- > 1) Strcat(monbuf, ", ");
					}
					if (useemon && mtmp->minvis) {
						Strcat(monbuf, "see invisible");
						if (ways_seen-- > 1) Strcat(monbuf, ", ");
					}
					if ((!mtmp->minvis || See_invisible) &&
						see_with_infrared(mtmp)) {
						Strcat(monbuf, "infravision");
						if (ways_seen-- > 1) Strcat(monbuf, ", ");
					}
					if (tp_sensemon(mtmp)) {
						Strcat(monbuf, "telepathy");
						if (ways_seen-- > 1) Strcat(monbuf, ", ");
					}
					if (useemon && xraydist > 0 &&
						distu(mtmp->mx, mtmp->my) <= xraydist) {
						/* Eyes of the Overworld */
						Strcat(monbuf, "astral vision");
						if (ways_seen-- > 1) Strcat(monbuf, ", ");
					}
					if (Detect_monsters) {
						Strcat(monbuf, "monster detection");
						if (ways_seen-- > 1) Strcat(monbuf, ", ");
					}
					if (MATCH_WARN_OF_MON(mtmp)) {
						char wbuf[BUFSZ];
						if (Hallucination)
							Strcat(monbuf, "paranoid delusion");
						else {
							Sprintf(wbuf, "warned of %s",
									makeplural(mtmp->data->mname));
							Strcat(monbuf, wbuf);
						}
						if (ways_seen-- > 1) Strcat(monbuf, ", ");
					}
				}
			}
		}
    }
    else if (glyph_is_object(glyph)) {
		struct obj *otmp = vobj_at(x,y);
		
		if (!otmp || otmp->otyp != glyph_to_obj(glyph)) {
			if (glyph_to_obj(glyph) != STRANGE_OBJECT) {
				otmp = mksobj(glyph_to_obj(glyph), FALSE, FALSE);
				if (otmp->oclass == COIN_CLASS)
					otmp->quan = 2L; /* to force pluralization */
				else if (otmp->otyp == SLIME_MOLD)
					otmp->spe = context.current_fruit;	/* give the fruit a type */
				Strcpy(buf, distant_name(otmp, xname));
				dealloc_obj(otmp);
			}
		} else
			Strcpy(buf, distant_name(otmp, xname));
		
		if (levl[x][y].typ == STONE || levl[x][y].typ == SCORR)
			Strcat(buf, " embedded in stone");
		else if (IS_WALL(levl[x][y].typ) || levl[x][y].typ == SDOOR)
			Strcat(buf, " embedded in a wall");
		else if (closed_door(x,y))
			Strcat(buf, " embedded in a door");
		else if (is_pool(x,y))
			Strcat(buf, " in water");
		else if (is_lava(x,y))
			Strcat(buf, " in molten lava");	/* [can this ever happen?] */
    } else if (glyph_is_trap(glyph)) {
		int tnum = what_trap(glyph_to_trap(glyph),rn2_on_display_rng);
		Strcpy(buf, defsyms[trap_to_defsym(tnum)].explanation);
    } else if(!glyph_is_cmap(glyph)) {
		Strcpy(buf,"dark part of a room");
    } else switch(glyph_to_cmap(glyph)) {
		case S_altar:
			if(!In_endgame(&u.uz))
				Sprintf(buf, "%s altar",
						align_str(Amask2align(levl[x][y].altarmask & ~AM_SHRINE)));
			else Sprintf(buf, "aligned altar");
			break;
		case S_ndoor:
			if (is_drawbridge_wall(x, y) >= 0)
				Strcpy(buf,"open drawbridge portcullis");
			else if ((levl[x][y].doormask & ~D_TRAPPED) == D_BROKEN)
				Strcpy(buf,"broken door");
			else
				Strcpy(buf,"doorway");
			break;
		case S_cloud:
			Strcpy(buf, Is_airlevel(&u.uz) ? "cloudy area" : "fog/vapor cloud");
			break;
		default:
			Strcpy(buf,defsyms[glyph_to_cmap(glyph)].explanation);
			break;
    }
	
    return ((pm && !Hallucination) ? pm : (struct permonst *) 0);
}

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


