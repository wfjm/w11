# $Id: Makefile 311 2010-06-30 17:52:37Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2010-05-23   293   1.0    Initial version (cloned..)
#
VBOM_all = $(wildcard *.vbom)
NGC_all  = $(VBOM_all:.vbom=.ngc)
#
ISE_PATH = xc3s1200e-fg320-4
#
.phony : all clean
#
all : $(NGC_all)
#
clean : ise_clean
#
#----
#
include $(RETROBASE)/rtl/vlib/Makefile.xflow
#
include $(VBOM_all:.vbom=.dep_xst)
#
