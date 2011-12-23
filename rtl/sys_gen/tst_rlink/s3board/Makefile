# $Id: Makefile 442 2011-12-23 10:03:28Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2011-12-22   442   1.0    Initial version
#
VBOM_all  = $(wildcard *.vbom)
BIT_all   = $(VBOM_all:.vbom=.bit)
#
ISE_BOARD = s3board
ISE_PATH  = xc3s1000-ft256-4
#
.PHONY : all clean
#
all : $(BIT_all)
#
clean : ise_clean
	rm -f sys_tst_rlink_s3.ucf
#
#----
#
include $(RETROBASE)/rtl/make/generic_xflow.mk
include $(RETROBASE)/rtl/make/generic_ghdl.mk
#
include $(VBOM_all:.vbom=.dep_xst)
include $(VBOM_all:.vbom=.dep_ghdl)
#
