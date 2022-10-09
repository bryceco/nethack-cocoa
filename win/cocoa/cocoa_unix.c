//
//  cocoa_unix.c
//  NetHackCocoa
//
//  Created by Bryce Cogswell on 1/2/21.
//

/* NetHack 3.6	pcunix.c	$NHDT-Date: 1432512787 2015/05/25 00:13:07 $  $NHDT-Branch: master $:$NHDT-Revision: 1.34 $ */
/* Copyright (c) Stichting Mathematisch Centrum, Amsterdam, 1985. */
/*-Copyright (c) Michael Allison, 2006. */
/* NetHack may be freely redistributed.  See license for details. */

/* This file collects some Unix dependencies; pager.c contains some more */

#include "hack.h"

#include <sys/stat.h>
#include <fcntl.h>
#include <sys/errno.h>


#if defined(TTY_GRAPHICS)
extern void NDECL(backsp);
extern void NDECL(clear_screen);
#endif

#ifdef WANT_GETHDATE
static struct stat hbuf;
#endif

#ifdef PC_LOCKING
static int NDECL(eraseoldlocks);
#endif

#ifdef PC_LOCKING
#ifndef SELF_RECOVER
static int
eraseoldlocks()
{
	register int i;

	/* cannot use maxledgerno() here, because we need to find a lock name
	 * before starting everything (including the dungeon initialization
	 * that sets astral_level, needed for maxledgerno()) up
	 */
	for (i = 1; i <= MAXDUNGEON * MAXLEVEL + 1; i++) {
		/* try to remove all */
		set_levelfile_name(lock, i);
		(void) unlink(fqname(lock, LEVELPREFIX, 0));
	}
	set_levelfile_name(lock, 0);
#ifdef HOLD_LOCKFILE_OPEN
	really_close();
#endif
	if (unlink(fqname(lock, LEVELPREFIX, 0)))
		return 0; /* cannot remove it */
	return (1);   /* success! */
}
#endif /* SELF_RECOVER */

void
getlock()
{
	register int fd, c, ci, ct, ern;
	int fcmask = FCMASK;
	char tbuf[BUFSZ];
	const char *fq_lock;
#if defined(MSDOS) && defined(NO_TERMS)
	int grmode = iflags.grmode;
#endif
	boolean resuming = TRUE;

	/* we ignore QUIT and INT at this point */
	if (!lock_file(HLOCK, LOCKPREFIX, 10)) {
		wait_synch();
#if defined(CHDIR) && !defined(NOCWD_ASSUMPTIONS)
		chdirx(orgdir, 0);
#endif
		error("Quitting.");
	}

	/* regularize(lock); */ /* already done in pcmain */
	Sprintf(tbuf, "%s", fqname(lock, LEVELPREFIX, 0));
	set_levelfile_name(lock, 0);
	fq_lock = fqname(lock, LEVELPREFIX, 1);
	if ((fd = open(fq_lock, 0)) == -1) {
		if (errno == ENOENT)
			goto gotlock; /* no such file */
#if defined(CHDIR) && !defined(NOCWD_ASSUMPTIONS)
		chdirx(orgdir, 0);
#endif
		perror(fq_lock);
		unlock_file(HLOCK);
		error("Cannot open %s", fq_lock);
	}

	(void) nhclose(fd);

	if (iflags.window_inited) {
#ifdef SELF_RECOVER
		c = yn("There are files from a game in progress under your name. "
			   "Recover?");
#else
		pline("There is already a game in progress under your name.");
		pline("You may be able to use \"recover %s\" to get it back.\n",
			  tbuf);
		c = yn("Do you want to destroy the old game?");
#endif
	} else {
#if defined(MSDOS) && defined(NO_TERMS)
		grmode = iflags.grmode;
		if (grmode)
			gr_finish();
#endif
		c = 'n';
		ct = 0;
#ifdef SELF_RECOVER
		printf("There are files from a game in progress under your name. "
			  "Recover? [yn]");
#else
		printf("\nThere is already a game in progress under your name.\n");
		printf("If this is unexpected, you may be able to use \n");
		printf("\"recover %s\" to get it back.", tbuf);
		printf("\nDo you want to destroy the old game? [yn] ");
#endif
		while ((ci = nhgetch()) != '\n') {
			if (ct > 0) {
				printf("\b \b");
				ct = 0;
				c = 'n';
			}
			if (ci == 'y' || ci == 'n' || ci == 'Y' || ci == 'N') {
				ct = 1;
				c = ci;
				printf("%c", c);
			}
		}
	}
	if (c == 'y' || c == 'Y')
#ifndef SELF_RECOVER
		if (eraseoldlocks()) {
			goto gotlock;
		} else {
			unlock_file(HLOCK);
#if defined(CHDIR) && !defined(NOCWD_ASSUMPTIONS)
			chdirx(orgdir, 0);
#endif
			error("Couldn't destroy old game.");
		}
#else /*SELF_RECOVER*/
		if (recover_savefile()) {
#if defined(TTY_GRAPHICS)
			if (WINDOWPORT("tty"))
				clear_screen(); /* display gets fouled up otherwise */
#endif
			goto gotlock;
		} else {
			unlock_file(HLOCK);
#if defined(CHDIR) && !defined(NOCWD_ASSUMPTIONS)
			chdirx(orgdir, 0);
#endif
			error("Couldn't recover old game.");
		}
#endif /*SELF_RECOVER*/
	else {
		unlock_file(HLOCK);
		resuming = FALSE;
//#if defined(CHDIR) && !defined(NOCWD_ASSUMPTIONS)
//		chdirx(orgdir, 0);
//#endif
//		error("%s", "Cannot start a new game.");
	}

	if (!resuming) {
		boolean neednewlock = (!*plname);
		/* new game:  start by choosing role, race, etc;
		   player might change the hero's name while doing that,
		   in which case we try to restore under the new name
		   and skip selection this time if that didn't succeed */
		if (!iflags.renameinprogress || iflags.defer_plname || neednewlock) {
			player_selection();
			if (iflags.renameinprogress) {
				/* player has renamed the hero while selecting role;
				   if locking alphabetically, the existing lock file
				   can still be used; otherwise, discard current one
				   and create another for the new character name */
				if (!locknum) {
					delete_levelfile(0); /* remove empty lock file */
					getlock();
				}
			}
		}
		newgame();
	}

gotlock:
	fd = creat(fq_lock, fcmask);
	if (fd == -1)
		ern = errno;
	unlock_file(HLOCK);
	if (fd == -1) {
#if defined(CHDIR) && !defined(NOCWD_ASSUMPTIONS)
		chdirx(orgdir, 0);
#endif
		error("cannot creat file (%s.)", fq_lock);
	} else {
		if (write(fd, (char *) &hackpid, sizeof(hackpid))
			!= sizeof(hackpid)) {
#if defined(CHDIR) && !defined(NOCWD_ASSUMPTIONS)
			chdirx(orgdir, 0);
#endif
			error("cannot write lock (%s)", fq_lock);
		}
		if (nhclose(fd) == -1) {
#if defined(CHDIR) && !defined(NOCWD_ASSUMPTIONS)
			chdirx(orgdir, 0);
#endif
			error("cannot close lock (%s)", fq_lock);
		}
	}
#if defined(MSDOS) && defined(NO_TERMS)
	if (grmode)
		gr_init();
#endif
}
#endif /* PC_LOCKING */

void
regularize(s)
/*
 * normalize file name - we don't like .'s, /'s, spaces, and
 * lots of other things
 */
register char *s;
{
	register char *lp;

	for (lp = s; *lp; lp++)
		if (*lp <= ' ' || *lp == '"' || (*lp >= '*' && *lp <= ',')
			|| *lp == '.' || *lp == '/' || (*lp >= ':' && *lp <= '?') ||
#ifdef OS2
			*lp == '&' || *lp == '(' || *lp == ')' ||
#endif
			*lp == '|' || *lp >= 127 || (*lp >= '[' && *lp <= ']'))
			*lp = '_';
}

#ifdef __EMX__
void
seteuid(int i)
{
	;
}
#endif


boolean
file_exists(path)
const char *path;
{
	struct stat sb;

	/* Just see if it's there - trying to figure out if we can actually
	 * execute it in all cases is too hard - we really just want to
	 * catch typos in SYSCF.
	 */
	if (stat(path, &sb)) {
		return FALSE;
	}
	return TRUE;
}


void set_fqn_prefixes(void)
{
	char dirbuf[1024];
	char * nethackdir = nh_getenv("NETHACKDIR");
	if (!nethackdir)
		nethackdir = nh_getenv("HACKDIR");
	if (!nethackdir) {
		char * home = getenv("HOME");
		strcpy(dirbuf,home);
		strcat(dirbuf,"/nethackdir");
		nethackdir = dirbuf;
	}

	// create nethackdir
	mkdir(nethackdir,0777);

	// create nethackdir/perm
	char tmpfile[1024];
	strcpy(tmpfile,nethackdir);
	strcat(tmpfile,"/perm");
	close(open(tmpfile,O_CREAT|O_WRONLY,0777));

	// create nethackdir/record
	strcpy(tmpfile,nethackdir);
	strcat(tmpfile,"/record");
	close(open(tmpfile,O_CREAT|O_WRONLY,0777));

	// create nethackdir/logfile
	strcpy(tmpfile,nethackdir);
	strcat(tmpfile,"/logfile");
	close(open(tmpfile,O_CREAT|O_WRONLY,0777));

	// create nethackdir/xlogfile
	strcpy(tmpfile,nethackdir);
	strcat(tmpfile,"/xlogfile");
	close(open(tmpfile,O_CREAT|O_WRONLY,0777));

	// create nethackdir/save
	strcpy(tmpfile,nethackdir);
	strcat(tmpfile,"/save");
	mkdir(tmpfile,0777);

	// set fqnames
	int len = strlen(nethackdir);
	char * prefix = (char *) alloc(len + 2);
	Strcpy(prefix, nethackdir);
	if (prefix[len - 1] != '/') {
		prefix[len] = '/';
		prefix[len + 1] = '\0';
	}
	fqn_prefix[SCOREPREFIX] = prefix;
	fqn_prefix[LEVELPREFIX] = prefix;
	fqn_prefix[SAVEPREFIX] = prefix;
	fqn_prefix[BONESPREFIX] = prefix;
	fqn_prefix[LOCKPREFIX] = prefix;
	fqn_prefix[TROUBLEPREFIX] = prefix;
}
