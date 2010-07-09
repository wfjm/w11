# $Id: Makefile 311 2010-06-30 17:52:37Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2007-12-14   101   1.0    Initial version
#
#
.phony : clean
#
clean : ghdl_clean
#
#-----
#
include $(RETROBASE)/rtl/vlib/Makefile.ghdl
#
VBOM_all = $(wildcard *.vbom)
#
include $(VBOM_all:.vbom=.dep_ghdl)
#
