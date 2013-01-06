# $Id: Makefile 472 2013-01-06 14:39:10Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2013-01-06   472   1.0    Initial version
#
#
VBOM_all  = $(wildcard *.vbom)
BIT_all   = $(VBOM_all:.vbom=.bit)
#
ISE_BOARD = atlys
ISE_PATH  = xc6slx45-csg324-2
FX2_FILE  = nexys3_jtag_2fifo_ic.ihx
#
XFLOWOPT_SYN = syn_s6_speed.opt
XFLOWOPT_IMP = imp_s6_speed.opt
#
.PHONY : all clean
#
all : $(BIT_all)
#
clean : ise_clean
	rm -f $(VBOM_all:.vbom=.ucf)
#
#----
#
include $(RETROBASE)/rtl/make/generic_xflow.mk
include $(RETROBASE)/rtl/make/generic_ghdl.mk
#
include $(VBOM_all:.vbom=.dep_xst)
include $(VBOM_all:.vbom=.dep_ghdl)
#
