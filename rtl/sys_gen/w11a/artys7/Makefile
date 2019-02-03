# $Id: Makefile 1105 2019-01-12 19:52:45Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2019-01-12  1105   1.0    Initial version
#
VBOM_all  = sys_w11a_as7.vbom
BIT_all   = $(VBOM_all:.vbom=.bit)
#
include ${RETROBASE}/rtl/make_viv/viv_default_artys7.mk
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
