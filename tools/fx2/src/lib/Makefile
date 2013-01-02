# $Id: Makefile 394 2011-07-17 17:03:19Z mueller $
#-----------------------------------------------------------------------------
# Makefile for FX2 library code
#-----------------------------------------------------------------------------
# Copyright (C) 2007 Kolja Waschk, ixo.de
#-----------------------------------------------------------------------------
# This code is part of usbjtag. usbjtag is free software; you can redistribute
# it and/or modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of the License,
# or (at your option) any later version. usbjtag is distributed in the hope
# that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.  You should have received a
# copy of the GNU General Public License along with this program in the file
# COPYING; if not, write to the Free Software Foundation, Inc., 51 Franklin
# St, Fifth Floor, Boston, MA  02110-1301  USA
#-----------------------------------------------------------------------------

CC=sdcc
CFLAGS+=-mmcs51 --no-xinit-opt -I.
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




