# $Id: Makefile 1176 2019-06-30 07:16:06Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2011-2014 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# Code was forked from ixo-jtag.svn.sourceforge.net on 2011-07-17
#
# - original copyright and licence disclaimer --------------------------------
# - Copyright 2007 Kolja Waschk, ixo.de
# - This code is part of usbjtag. usbjtag is free software;
#-----------------------------------------------------------------------------
# Makefile for FX2 library code
#
# Revision History in retro projects
# 
# Date         Rev Version  Comment
# 2014-11-16   604   1.1    add sdcc 3.x migration support
# 2011-07-17   394   1.0    Initial version (from ixo-jtag/usb_jtag Rev 204)
#
#-----------------------------------------------------------------------------

#
# defs for sdcc 2.9 to 3.x transition handling -------------------------
#
include ../sdccdefs.mk

CFLAGS+=-mmcs51 --no-xinit-opt -I.
CFLAGS+=${CC29COMPOPT}

CPPFLAGS+=
OBJS=delay.rel fx2utils.rel i2c.rel isr.rel timer.rel usb_common.rel
AR=sdcclib

(%.rel) : %.c
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $< -o $*.rel
	$(AR) -a $@ $*.rel
	rm $*.rel

libfx2.lib: libfx2.lib($(OBJS))

clean:
	rm -f *.lst *.asm *.lib *.sym *.rel *.lib




