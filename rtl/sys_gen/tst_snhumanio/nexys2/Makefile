# $Id: Makefile 410 2011-09-18 11:23:09Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2011-09-17   410   1.0    Initial version
#
VBOM_all  = $(wildcard *.vbom)
BIT_all   = $(VBOM_all:.vbom=.bit)
#
ISE_BOARD = nexys2
ISE_PATH  = xc3s1200e-fg320-4
#
.PHONY : all clean
#
all : $(BIT_all)
#
clean : ise_clean
	rm -f sys_tst_snhumanio_n2.ucf
#
#----
#
include $(RETROBASE)/rtl/make/generic_xflow.mk
include $(RETROBASE)/rtl/make/generic_ghdl.mk
#
include $(VBOM_all:.vbom=.dep_xst)
include $(VBOM_all:.vbom=.dep_ghdl)
#
