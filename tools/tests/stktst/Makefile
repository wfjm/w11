# $Id: Makefile 1267 2022-08-02 06:27:29Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2022- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
stktst : stktst.o dotst.o
	cc -o stktst stktst.o dotst.o

stktst.o : stktst.c
	cc -O -c stktst.c

clean :	
	rm  -f *.o stktst
