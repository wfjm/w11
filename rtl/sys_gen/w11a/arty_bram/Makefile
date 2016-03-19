# $Id: Makefile 737 2016-02-28 09:07:18Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2016-02-27   736   1.0    Initial version
#
VBOM_all  = sys_w11a_br_arty.vbom
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
