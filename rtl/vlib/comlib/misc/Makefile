# $Id: Makefile 311 2010-06-30 17:52:37Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2007-11-26    98   1.0    Initial version
#
EXE_all = gen_crc8_tbl gen_crc8_tbl_check
#
#
.phony : all clean
#
all : $(EXE_all)
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
#-----
#
