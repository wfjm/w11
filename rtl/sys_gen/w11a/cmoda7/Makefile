# $Id: Makefile 914 2017-06-25 06:17:18Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2017-06-24   914   1.0    Initial version
#
VBOM_all  = sys_w11a_c7.vbom
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
