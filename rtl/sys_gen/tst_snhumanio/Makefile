# $Id: Makefile 410 2011-09-18 11:23:09Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2011-09-17   410   1.0    Initial version
#
VBOM_all = $(wildcard *.vbom)
NGC_all  = $(VBOM_all:.vbom=.ngc)
#
ISE_PATH = xc3s1000-ft256-4
#
.PHONY : all clean
#
all : $(NGC_all)
#
clean : ise_clean
#
#----
#
include $(RETROBASE)/rtl/make/generic_xflow.mk
#
include $(VBOM_all:.vbom=.dep_xst)
#
