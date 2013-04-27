# $Id: Makefile 509 2013-04-21 20:46:20Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2013-04-20   509   1.2    add fx2 support
# 2011-11-20   430   1.0    Initial version (derived from _n2 version)
#
VBOM_all  = $(wildcard *.vbom)
BIT_all   = $(VBOM_all:.vbom=.bit)
#
include $(RETROBASE)/rtl/make/xflow_default_nexys3.mk
FX2_FILE  = nexys3_jtag_2fifo_ic.ihx
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
ifndef DONTINCDEP
include $(VBOM_all:.vbom=.dep_xst)
include $(VBOM_all:.vbom=.dep_ghdl)
endif
#
