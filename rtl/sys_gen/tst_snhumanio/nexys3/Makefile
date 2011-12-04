# $Id: Makefile 433 2011-11-27 22:04:39Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2011-11-27   433   1.0    Initial version
#
VBOM_all  = $(wildcard *.vbom)
BIT_all   = $(VBOM_all:.vbom=.bit)
#
ISE_BOARD = nexys3
ISE_PATH  = xc6slx16-csg324-2
#
XFLOWOPT_SYN = syn_s6_speed.opt
XFLOWOPT_IMP = imp_s6_speed.opt
#
.PHONY : all clean
#
all : $(BIT_all)
#
clean : ise_clean
	rm -f sys_tst_snhumanio_n3.ucf
#
#----
#
include $(RETROBASE)/rtl/make/generic_xflow.mk
include $(RETROBASE)/rtl/make/generic_ghdl.mk
#
include $(VBOM_all:.vbom=.dep_xst)
include $(VBOM_all:.vbom=.dep_ghdl)
#
