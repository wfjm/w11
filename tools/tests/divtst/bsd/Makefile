# $Id: Makefile 1266 2022-07-30 17:33:07Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2014-2022 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
divtst : divtst.o dotst.o getpsw.o
	cc -o divtst divtst.o dotst.o getpsw.o

divtst.o : divtst.c
	cc -O -c divtst.c

clean :	
	rm  -f *.o divtst
