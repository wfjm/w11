# $Id: Makefile 311 2010-06-30 17:52:37Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2007-12-09   100   1.0.1  drop ISE_p definition
# 2007-06-03    45   1.0    Initial version
#
VBOM_all = $(wildcard *.vbom)
NGC_all  = $(VBOM_all:.vbom=.ngc)
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
