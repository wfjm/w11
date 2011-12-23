# $Id: Makefile 438 2011-12-11 23:40:52Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2011-12-11   438   1.0    Initial version
#
VBOM_all = $(wildcard *.vbom)
NGC_all  = $(VBOM_all:.vbom=.ngc)
#
ISE_PATH = xc3s1000-ft256-4
#
.PHONY : all clean realclean
#
all : $(NGC_all)
#
clean : ise_clean
#
#
#----
#
include $(RETROBASE)/rtl/make/generic_xflow.mk
#
include $(VBOM_all:.vbom=.dep_xst)
#
