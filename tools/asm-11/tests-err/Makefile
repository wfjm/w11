# $Id: Makefile 1176 2019-06-30 07:16:06Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2013-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History: 
# Date         Rev Version  Comment
# 2018-11-03  1065   1.1    sort file list
# 2013-03-22   496   1.0    Initial version
#---
#
MAC_all    = $(sort $(wildcard *.mac))
LSTERR_all = $(MAC_all:.mac=.lsterr)
LDART_all  = $(MAC_all:.mac=.ldart)
LSTRT_all  = $(MAC_all:.mac=.lstrt)
#
include ${RETROBASE}/tools/make/generic_asm11.mk
#
.PHONY : def alllst allrt allexp clean cleanrt
#
def : alllst
#
alllst : $(LSTERR_all)
#
allrt : $(LSTRT_all)
#
allexp : $(LSTERR_all)
	@ asm-11_expect $^
#
clean :
	@ rm -f $(LSTERR_all)
	@ echo "Listing files removed"

cleanrt :
	@ rm -f $(LDART_all) $(LSTRT_all)
	@ echo "RT-11 generated files removed"
