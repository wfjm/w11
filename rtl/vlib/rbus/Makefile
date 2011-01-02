# $Id: Makefile 343 2010-12-05 21:24:38Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2007-12-09   100   1.0.1  drop ISE_p definition
# 2007-07-06    64   1.0    Initial version
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
