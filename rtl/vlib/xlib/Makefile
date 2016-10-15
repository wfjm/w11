# $Id: Makefile 749 2016-03-20 22:09:03Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2016-03-20   749   1.0    Initial version
#
VBOM_all = $(wildcard *.vbom)
DCP_all  = $(VBOM_all:.vbom=_syn.dcp)
#
# reference board for test synthesis is Artix-7 based Nexys4
ifndef XTW_BOARD
  XTW_BOARD=nexys4
endif
include ${RETROBASE}/rtl/make_viv/viv_default_$(XTW_BOARD).mk
#
.PHONY : catch all 
#
catch : 
	@echo "no default target defined, use"
	@echo "  make all"
	@echo "  make <module>_syn.dcp"
	@exit 1
#
all : $(DCP_all)
#
clean : viv_clean
#
#-----
#
include ${RETROBASE}/rtl/make_viv/generic_vivado.mk
#
VBOM_all = $(wildcard *.vbom)
#
ifndef DONTINCDEP
include $(VBOM_all:.vbom=.dep_vsyn)
endif
#
