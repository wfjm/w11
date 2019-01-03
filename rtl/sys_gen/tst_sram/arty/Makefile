# $Id: Makefile 1071 2018-11-17 20:53:26Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2018-11-17  1071   1.0    Initial version
#
VBOM_all  = sys_tst_sram_arty.vbom
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
