# $Id: Makefile 441 2011-12-20 17:01:16Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2011-10-14   416   1.0    Initial version
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
	rm -f sys_tst_serloop_s3.ucf
#
#----
#
include $(RETROBASE)/rtl/make/generic_xflow.mk
include $(RETROBASE)/rtl/make/generic_ghdl.mk
#
include $(VBOM_all:.vbom=.dep_xst)
include $(VBOM_all:.vbom=.dep_ghdl)
#
