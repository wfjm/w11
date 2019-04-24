# $Id: Makefile 1135 2019-04-23 12:56:23Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2013-03-22   496   1.0    Initial version
#---
#
MAC_all = $(wildcard *.mac)
LDA_all = $(MAC_all:.mac=.lda)
COF_all = $(MAC_all:.mac=.cof)
LST_all = $(MAC_all:.mac=.lst)
#
include ${RETROBASE}/tools/make/generic_asm11.mk
#
.PHONY : alllda allcof alllst clean
#
def : alllda
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
