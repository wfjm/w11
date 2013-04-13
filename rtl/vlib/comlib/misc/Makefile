# $Id: Makefile 477 2013-01-27 14:07:10Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2011-08-13   405   1.1    use includes from rtl/make
# 2007-11-26    98   1.0    Initial version
#
EXE_all = gen_crc8_tbl gen_crc8_tbl_check
#
#
.PHONY : all clean
#
all : $(EXE_all)
#
clean : ghdl_clean
#
#-----
#
include $(RETROBASE)/rtl/make/generic_ghdl.mk
#
VBOM_all = $(wildcard *.vbom)
#
ifndef DONTINCDEP
include $(VBOM_all:.vbom=.dep_ghdl)
endif
#
