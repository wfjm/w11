# $Id: Makefile 1092 2018-12-24 08:01:50Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2018-12-23  1092   1.0    Initial version
#
VBOM_all  = sys_tst_mig_arty.vbom
BIT_all   = $(VBOM_all:.vbom=.bit)
#
include ${RETROBASE}/rtl/make_viv/viv_default_arty.mk
#
.PHONY : all clean
#
all : $(BIT_all)
#
clean : viv_clean
#
#----
#
include ${RETROBASE}/rtl/make_viv/generic_vivado.mk
#
ifndef DONTINCDEP
include $(VBOM_all:.vbom=.dep_vsyn)
endif
#
