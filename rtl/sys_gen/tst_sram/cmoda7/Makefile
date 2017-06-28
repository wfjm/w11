# $Id: Makefile 912 2017-06-11 18:30:03Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2017-06-11   912   1.0    Initial version
#
VBOM_all  = sys_tst_sram_c7.vbom
BIT_all   = $(VBOM_all:.vbom=.bit)
#
include ${RETROBASE}/rtl/make_viv/viv_default_cmoda7.mk
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
