# $Id: Makefile 477 2013-01-27 14:07:10Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2012-04-09   461   1.0    Initial version
#
#
VBOM_all  = $(wildcard *.vbom)
BIT_all   = $(VBOM_all:.vbom=.bit)
#
include $(RETROBASE)/rtl/make/xflow_default_nexys3.mk
FX2_FILE  = nexys3_jtag_3fifo_ic.ihx
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
