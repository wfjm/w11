# $Id: Makefile 733 2016-02-20 12:24:13Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2016-02-14   731   1.0    Initial version
#
EXE_all = tb_tst_rlink_arty
#
include ${RETROBASE}/rtl/make_viv/viv_default_arty.mk
#
.PHONY : all all_ssim clean
#
all      : $(EXE_all)
all_ssim : $(EXE_all:=_ssim)
#
clean : viv_clean ghdl_clean
#
#-----
#
include ${RETROBASE}/rtl/make_viv/generic_vivado.mk
include ${RETROBASE}/rtl/make_viv/generic_ghdl.mk
#
VBOM_all = $(wildcard *.vbom)
#
ifndef DONTINCDEP
include $(VBOM_all:.vbom=.dep_vsyn)
include $(VBOM_all:.vbom=.dep_ghdl)
include $(wildcard *.o.dep_ghdl)
endif
#
