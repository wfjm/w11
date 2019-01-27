# $Id: Makefile 1101 2019-01-02 21:22:37Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2019-01-02  1101   1.0    Initial version
#
VBOM_all  = sys_w11a_n4d.vbom
BIT_all   = $(VBOM_all:.vbom=.bit)
#
include ${RETROBASE}/rtl/make_viv/viv_default_nexys4d.mk
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
