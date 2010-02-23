//
//  MainView.m
//  NetHack
//
//  Created by dirk on 2/1/10.
//  Copyright 2010 Dirk Zimmermann. All rights reserved.
//  Copyright 2010 Bryce Cogswell. All rights reserved.
/* Copyright (c) Stichting Mathematisch Centrum, Amsterdam, 1985. */
//

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

#import "MainView.h"
#import "NhWindow.h"
#import "NhMapWindow.h"
#import "TileSet.h"
#import "NhEventQueue.h"
#import "NhTextInputEvent.h"
#import "NhEvent.h"
#import "wincocoa.h"
#import "TooltipWindow.h"


@implementation MainView

-(BOOL)setTileSet:(NSString *)tileSetName size:(NSSize)size
{
	NSImage *tilesetImage = [NSImage imageNamed:tileSetName];
	if ( tilesetImage == nil ) {
		NSURL * url = [NSURL URLWithString:tileSetName];
		tilesetImage = [[[NSImage alloc] initByReferencingURL:url] autorelease];
		if ( tilesetImage == nil ) {
			return NO;
		}
	}
	
	// make sure dimensions work
	NSSize imageSize = [tilesetImage size];
	if ( (imageSize.width / size.width) * (imageSize.height / size.height) < 1014 ) {
		// not enough images
		return NO;
	}
	
	tileSize = size;

	// update our bounds
	NSRect frame = [self frame];
	frame.size = NSMakeSize( COLNO*tileSize.width, ROWNO*tileSize.height );
	[self setFrame:frame];

	TileSet *tileSet = [[[TileSet alloc] initWithImage:tilesetImage tileSize:tileSize] autorelease];
	[TileSet setInstance:tileSet];
	
	[self centerHero];
	[self setNeedsDisplay:YES];
	
	return YES;
}

- (id)initWithFrame:(NSRect)frame {

	if (self = [super initWithFrame:frame]) {
		
		petMark = [NSImage imageNamed:@"petmark.png"];
#if 0
		[self setTileSet:@"absurd128.png" size:NSMakeSize(128,128)];
#else
		[self setTileSet:@"kins32.bmp" size:NSMakeSize(32,32)];
#endif		
		// we need to know when we scroll
		NSClipView * clipView = [[self enclosingScrollView] contentView];
		[clipView setPostsBoundsChangedNotifications: YES];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(boundsDidChangeNotification:) 
											name:NSViewBoundsDidChangeNotification object:clipView];
		
	}
		
	return self;
}

- (void)cliparoundX:(int)x y:(int)y {
	clipX = x;
	clipY = y;
}


// if we're too close to edge of window then scroll us back
- (void)centerHero
{
	int border = 4;
	NSPoint center = NSMakePoint( (u.ux+0.5)*tileSize.width, ((ROWNO-1-u.uy)+0.5)*tileSize.height );
	NSRect rect = NSMakeRect( center.x-tileSize.width*border, center.y-tileSize.height*border, tileSize.width*2*border, tileSize.height*2*border );
	[self scrollRectToVisible:rect];	 	 
}

- (void)drawRect:(NSRect)rect 
{
	[[NSColor blackColor] setFill];
	[NSBezierPath fillRect:rect];
	
	NhMapWindow *map = (NhMapWindow *) [NhWindow mapWindow];
	if (map) {
		// since this coordinate system is right-handed, each tile starts above left
		// and draws the area below to the right, so we have to be one tile height off
		NSPoint start = NSMakePoint(0.0f,
									self.bounds.size.height-tileSize.height);
		
		NSImage * image = [[TileSet instance] image];
		
		for (int j = 0; j < ROWNO; ++j) {
			for (int i = 0; i < COLNO; ++i) {
				NSPoint p = NSMakePoint(start.x+i*tileSize.width,
										start.y-j*tileSize.height);
				NSRect r = NSMakeRect(p.x, p.y, tileSize.width, tileSize.height);
				if (NSIntersectsRect(r, rect)) {
					int glyph = [map glyphAtX:i y:j];
					if (glyph) {
						int ochar, ocolor;
						unsigned int special;
						mapglyph(glyph, &ochar, &ocolor, &special, i, j);
						NSRect srcRect = [[TileSet instance] sourceRectForGlyph:glyph];
						[image drawInRect:r fromRect:srcRect operation:NSCompositeCopy fraction:1.0f];
#if 0
						if (glyph_is_pet(glyph)) {
							[petMark drawInRect:r fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0f];
						}
#endif
					}
				}
			}
		}
	}
}

- (void)dealloc {
    [super dealloc];
}

#pragma mark NSResponder

- (BOOL)acceptsFirstResponder {
	return YES;
}
- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
	return YES;
}


- (void)mouseDown:(NSEvent *)theEvent
{
	NSPoint mouseLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	mouseLoc.x = (int)(mouseLoc.x / tileSize.width);
	mouseLoc.y = (int)(mouseLoc.y / tileSize.height);
	mouseLoc.y = ROWNO - 1 - mouseLoc.y;
	
	NhEvent * e = [NhEvent eventWithX:mouseLoc.x y:mouseLoc.y];
	[[NhEventQueue instance] addEvent:e];
}

- (void)cancelTooltip
{
	if ( tooltipTimer ) {
		[tooltipTimer invalidate];
		[tooltipTimer release];
		tooltipTimer = nil;
	}
	if ( tooltipWindow ) {
		[tooltipWindow close];	// automatically released when closed
		tooltipWindow = nil;
	}	
}


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
					otmp->spe = current_fruit;	/* give the fruit a type */
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
		int tnum = what_trap(glyph_to_trap(glyph));
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

static NSString * do_look( coord cc )
{
    char    out_str[BUFSZ], look_buf[BUFSZ];
    const char *x_str, *firstmatch = 0;
    struct permonst *pm = 0;
    int     i;
    int     sym;		/* typed symbol or converted glyph */
    int	    found;		/* count of matching syms found */
    boolean save_verbose;	/* saved value of flags.verbose */
    boolean from_screen;	/* question from the screen */
    boolean need_to_look;	/* need to get explan. from glyph */
    boolean hit_trap;		/* true if found trap explanation */
    int skipped_venom;		/* non-zero if we ignored "splash of venom" */
    static const char *mon_interior = "the interior of a monster";
	
	sym = 0;		/* gcc -Wall lint */
	
    /* Save the verbose flag, we change it later. */
    save_verbose = flags.verbose;
    flags.verbose = FALSE;

	/* Reset some variables. */
	need_to_look = FALSE;
	pm = (struct permonst *)0;
	skipped_venom = 0;
	found = 0;
	out_str[0] = '\0';
	
	if (from_screen) {
		int glyph;	/* glyph at selected position */
		
		/* Convert the glyph at the selected position to a symbol. */
		glyph = glyph_at(cc.x,cc.y);
		if (glyph_is_cmap(glyph)) {
			sym = showsyms[glyph_to_cmap(glyph)];
		} else if (glyph_is_trap(glyph)) {
			sym = showsyms[trap_to_defsym(glyph_to_trap(glyph))];
		} else if (glyph_is_object(glyph)) {
			sym = oc_syms[(int)objects[glyph_to_obj(glyph)].oc_class];
			if (sym == '`' && iflags.bouldersym && (int)glyph_to_obj(glyph) == BOULDER)
				sym = iflags.bouldersym;
		} else if (glyph_is_monster(glyph)) {
			/* takes care of pets, detected, ridden, and regular mons */
			sym = monsyms[(int)mons[glyph_to_mon(glyph)].mlet];
		} else if (glyph_is_swallow(glyph)) {
			sym = showsyms[glyph_to_swallow(glyph)+S_sw_tl];
		} else if (glyph_is_invisible(glyph)) {
			sym = DEF_INVISIBLE;
		} else if (glyph_is_warning(glyph)) {
			sym = glyph_to_warning(glyph);
			sym = warnsyms[sym];
		} else {
			impossible("do_look:  bad glyph %d at (%d,%d)",
					   glyph, (int)cc.x, (int)cc.y);
			sym = ' ';
		}
	}
	
	/*
	 * Check all the possibilities, saving all explanations in a buffer.
	 * When all have been checked then the string is printed.
	 */
	
	/* Check for monsters */
	for (i = 0; i < MAXMCLASSES; i++) {
		if (sym == (from_screen ? monsyms[i] : def_monsyms[i]) &&
			monexplain[i]) {
			need_to_look = TRUE;
			if (!found) {
				Sprintf(out_str, "%c       %s", sym, an(monexplain[i]));
				firstmatch = monexplain[i];
				found++;
			} else {
				found += append_str(out_str, an(monexplain[i]));
			}
		}
	}
	/* handle '@' as a special case if it refers to you and you're
	 playing a character which isn't normally displayed by that
	 symbol; firstmatch is assumed to already be set for '@' */
	if ((from_screen ?
		 (sym == monsyms[S_HUMAN] && cc.x == u.ux && cc.y == u.uy) :
		 (sym == def_monsyms[S_HUMAN] && !iflags.showrace)) &&
		!(Race_if(PM_HUMAN) || Race_if(PM_ELF)) && !Upolyd)
		found += append_str(out_str, "you");	/* tack on "or you" */
	
	/*
	 * Special case: if identifying from the screen, and we're swallowed,
	 * and looking at something other than our own symbol, then just say
	 * "the interior of a monster".
	 */
	if (u.uswallow && from_screen && is_swallow_sym(sym)) {
		if (!found) {
			Sprintf(out_str, "%c       %s", sym, mon_interior);
			firstmatch = mon_interior;
		} else {
			found += append_str(out_str, mon_interior);
		}
		need_to_look = TRUE;
	}
	
	/* Now check for objects */
	for (i = 1; i < MAXOCLASSES; i++) {
		if (sym == (from_screen ? oc_syms[i] : def_oc_syms[i])) {
			need_to_look = TRUE;
			if (from_screen && i == VENOM_CLASS) {
				skipped_venom++;
				continue;
			}
			if (!found) {
				Sprintf(out_str, "%c       %s", sym, an(objexplain[i]));
				firstmatch = objexplain[i];
				found++;
			} else {
				found += append_str(out_str, an(objexplain[i]));
			}
		}
	}
	
	if (sym == DEF_INVISIBLE) {
		if (!found) {
			Sprintf(out_str, "%c       %s", sym, an(invisexplain));
			firstmatch = invisexplain;
			found++;
		} else {
			found += append_str(out_str, an(invisexplain));
		}
	}
	
#define is_cmap_trap(i) ((i) >= S_arrow_trap && (i) <= S_polymorph_trap)
#define is_cmap_drawbridge(i) ((i) >= S_vodbridge && (i) <= S_hcdbridge)
	
	/* Now check for graphics symbols */
	for (hit_trap = FALSE, i = 0; i < MAXPCHARS; i++) {
		x_str = defsyms[i].explanation;
		if (sym == (from_screen ? showsyms[i] : defsyms[i].sym) && *x_str) {
			/* avoid "an air", "a water", or "a floor of a room" */
			int article = (i == S_room) ? 2 :		/* 2=>"the" */
			!(strcmp(x_str, "air") == 0 ||	/* 1=>"an"  */
			  strcmp(x_str, "water") == 0);	/* 0=>(none)*/
			
			if (!found) {
				if (is_cmap_trap(i)) {
					Sprintf(out_str, "%c       a trap", sym);
					hit_trap = TRUE;
				} else {
					Sprintf(out_str, "%c       %s", sym,
							article == 2 ? the(x_str) :
							article == 1 ? an(x_str) : x_str);
				}
				firstmatch = x_str;
				found++;
			} else if (!u.uswallow && !(hit_trap && is_cmap_trap(i)) &&
					   !(found >= 3 && is_cmap_drawbridge(i))) {
				found += append_str(out_str,
									article == 2 ? the(x_str) :
									article == 1 ? an(x_str) : x_str);
				if (is_cmap_trap(i)) hit_trap = TRUE;
			}
			
			if (i == S_altar || is_cmap_trap(i))
				need_to_look = TRUE;
		}
	}
	
	/* Now check for warning symbols */
	for (i = 1; i < WARNCOUNT; i++) {
		x_str = def_warnsyms[i].explanation;
		if (sym == (from_screen ? warnsyms[i] : def_warnsyms[i].sym)) {
			if (!found) {
				Sprintf(out_str, "%c       %s",
						sym, def_warnsyms[i].explanation);
				firstmatch = def_warnsyms[i].explanation;
				found++;
			} else {
				found += append_str(out_str, def_warnsyms[i].explanation);
			}
			/* Kludge: warning trumps boulders on the display.
			 Reveal the boulder too or player can get confused */
			if (from_screen && sobj_at(BOULDER, cc.x, cc.y))
				Strcat(out_str, " co-located with a boulder");
			break;	/* out of for loop*/
		}
	}
	
	/* if we ignored venom and list turned out to be short, put it back */
	if (skipped_venom && found < 2) {
		x_str = objexplain[VENOM_CLASS];
		if (!found) {
			Sprintf(out_str, "%c       %s", sym, an(x_str));
			firstmatch = x_str;
			found++;
		} else {
			found += append_str(out_str, an(x_str));
		}
	}
	
	/* handle optional boulder symbol as a special case */ 
	if (iflags.bouldersym && sym == iflags.bouldersym) {
		if (!found) {
			firstmatch = "boulder";
			Sprintf(out_str, "%c       %s", sym, an(firstmatch));
			found++;
		} else {
			found += append_str(out_str, "boulder");
		}
	}
	
	/*
	 * If we are looking at the screen, follow multiple possibilities or
	 * an ambiguous explanation by something more detailed.
	 */
	if (from_screen) {
		if (found > 1 || need_to_look) {
			char monbuf[BUFSZ];
			char temp_buf[BUFSZ];
			
			pm = lookat(cc.x, cc.y, look_buf, monbuf);
			firstmatch = look_buf;
			if (*firstmatch) {
				Sprintf(temp_buf, " (%s)", firstmatch);
				(void)strncat(out_str, temp_buf, BUFSZ-strlen(out_str)-1);
				found = 1;	/* we have something to look up */
			}
			if (monbuf[0]) {
				Sprintf(temp_buf, " [seen: %s]", monbuf);
				(void)strncat(out_str, temp_buf, BUFSZ-strlen(out_str)-1);
			}
		}
	}
	
	/* Finally, print out our explanation. */
	NSString * result;
	if (found) {
		result = [NSString stringWithUTF8String:out_str];
	} else {
		result = @"I've never heard of such things.";
	}

    flags.verbose = save_verbose;
    return result;
}



- (void)tooltipFired
{
	NSPoint point = [self convertPoint:tooltipPoint fromView:nil];
	if ( !NSPointInRect( point, [self bounds] ) )
		return;
	
	[self cancelTooltip];
		
	int tileX = (int)(point.x / tileSize.width);
	int tileY = (int)(point.y / tileSize.height);
	tileY = ROWNO - 1 - tileY;
	
#if 0
	char buf[ 100 ];
	buf[0] = 0;
	const char * feature = dfeature_at( tileX, tileY, buf);	
	if ( feature ) {
		NSString * text = [NSString stringWithUTF8String:feature];
		NSPoint pt = NSMakePoint( tooltipPoint.x + 2, tooltipPoint.y + 2 );
		tooltipWindow = [[TooltipWindow alloc] initWithText:text location:pt];
	}
#else
	coord pos = { tileX, tileY };
	NSString * text = do_look( pos );
	
	if ( text && [text length] ) {
		NSPoint pt = NSMakePoint( point.x + 2, point.y + 2 );
		pt = [self convertPointToBase:pt];
		pt = [[self window] convertBaseToScreen:pt];
		tooltipWindow = [[TooltipWindow alloc] initWithText:text location:pt];
	}
#endif
}

- (void) boundsDidChangeNotification:(NSNotification *)notification
{
	[self cancelTooltip];
}
- (void)mouseMoved:(NSEvent *)theEvent
{
	[self cancelTooltip];
	
	tooltipPoint = [theEvent locationInWindow];
	tooltipTimer = [[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tooltipFired) userInfo:nil repeats:NO] retain];
}



- (void)keyDown:(NSEvent *)theEvent 
{
	if ( [theEvent type] == NSKeyDown ) {
		wchar_t key = [WinCocoa keyWithKeyEvent:theEvent];
		if ( key ) {
			[[NhEventQueue instance] addKey:key];			
		}
	}
}

@end
