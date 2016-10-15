# $Id: Makefile 801 2016-08-27 16:47:01Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2016-08-26   801   1.1    use explicit VBOM_all, no wildcard
# 2011-11-27   433   1.0    Initial version
#
VBOM_all  = sys_tst_sram_n3.vbom
BIT_all   = $(VBOM_all:.vbom=.bit)
#
include ${RETROBASE}/rtl/make_ise/xflow_default_nexys3.mk
#
.PHONY : all clean
#
all : sys_tst_sram_n3.bit
#
clean : ise_clean
	rm -f $(VBOM_all:.vbom=.ucf)
#
#-----
#
include ${RETROBASE}/rtl/make_ise/generic_ghdl.mk
include ${RETROBASE}/rtl/make_ise/generic_xflow.mk
#
ifndef DONTINCDEP
include $(VBOM_all:.vbom=.dep_xst)
include $(VBOM_all:.vbom=.dep_ghdl)
endif
#
