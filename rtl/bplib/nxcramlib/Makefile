# $Id: Makefile 433 2011-11-27 22:04:39Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2011-11-26   433   1.0    Initial version (cloned..)
#
VBOM_all = $(wildcard *.vbom)
NGC_all  = $(VBOM_all:.vbom=.ngc)
#
ISE_PATH = xc3s1200e-fg320-4
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
