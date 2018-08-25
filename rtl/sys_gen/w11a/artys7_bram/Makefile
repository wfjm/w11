# $Id: Makefile 1038 2018-08-11 12:39:52Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2018-08-05  1038   1.0    Initial version
#
VBOM_all  = sys_w11a_br_as7.vbom
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
