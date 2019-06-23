# $Id: generic_asm11_def.mk 1168 2019-06-20 11:52:51Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History: 
# Date         Rev Version  Comment
# 2019-05-07  1147   1.0    Initial version
#---
#
MAC_all = $(wildcard *.mac)
LDA_all = $(MAC_all:.mac=.lda)
COF_all = $(MAC_all:.mac=.cof)
LST_all = $(MAC_all:.mac=.lst)
#
include ${RETROBASE}/tools/make/generic_asm11.mk
#
.PHONY : all alllda allcof alllst clean
#
all : alllda
#
alllda : $(LDA_all)
#
allcof : $(COF_all)
#
alllst : $(LST_all)
#
clean :
	@ rm -f $(LDA_all)
	@ echo "Object files removed"
	@ rm -f $(COF_all)
	@ echo "Compound files removed"
	@ rm -f $(LST_all)
	@ echo "Listing files removed"
