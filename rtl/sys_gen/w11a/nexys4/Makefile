# $Id: Makefile 801 2016-08-27 16:47:01Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2016-08-26   801   1.1    use explicit VBOM_all, no wildcard
# 2015-01-25   637   1.0    Initial version
#
VBOM_all  = sys_w11a_n4.vbom
BIT_all   = $(VBOM_all:.vbom=.bit)
#
include ${RETROBASE}/rtl/make_viv/viv_default_nexys4.mk
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
