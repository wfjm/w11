# $Id: Makefile 1067 2018-11-11 08:30:29Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2017-07-01   919   1.0    Initial version
#
VBOM_all = $(wildcard *.vbom)
DCP_all  = $(VBOM_all:.vbom=_syn.dcp)
#
# reference board for test synthesis is CmodA7
ifndef XTW_BOARD
  XTW_BOARD=cmoda7
endif
include ${RETROBASE}/rtl/make_viv/viv_default_$(XTW_BOARD).mk
#
.PHONY : catch all clean
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
