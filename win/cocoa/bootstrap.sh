#!/bin/sh

#
# Bootstrap
#
# 2010/03/19 Dirk Zimmermann
#
# Creates makedefs, levels etc.
#

pushd ../../sys/unix

# no symbolic links used to enable easier patching
sh setup.sh hints/unix

cd ../..

cd util && make spotless makedefs
cd src
../util/makedefs -v # date.h
../util/makedefs -p # pm.h
../util/makedefs -o # onames.h, dat/options?
../util/makedefs -m # monstr.c
../util/makedefs -f # filename.h

cd ..
cd dat && make spotless all

cd ..
cd src && make tile.c

popd
