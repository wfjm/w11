# $Id: Makefile 733 2016-02-20 12:24:13Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2016-02-07   729   1.0.1  add generic_xsim.mk
# 2015-02-21   649   1.0    Initial version
#
EXE_all = tb_tst_serloop1_n4
#
include ${RETROBASE}/rtl/make_viv/viv_default_nexys4.mk
#
.PHONY : all all_ssim clean
#
all      : $(EXE_all)
all_ssim : $(EXE_all:=_ssim)
all_osim : $(EXE_all:=_osim)
#
all_XSim      : $(EXE_all:=_XSim)
all_XSim_ssim : $(EXE_all:=_XSim_ssim)
all_XSim_osim : $(EXE_all:=_XSim_osim)
all_XSim_tsim : $(EXE_all:=_XSim_tsim)
#
clean : viv_clean ghdl_clean
#
#-----
#
include ${RETROBASE}/rtl/make_viv/generic_vivado.mk
include ${RETROBASE}/rtl/make_viv/generic_ghdl.mk
include ${RETROBASE}/rtl/make_viv/generic_xsim.mk
#
VBOM_all = $(wildcard *.vbom)
#
ifndef DONTINCDEP
include $(VBOM_all:.vbom=.dep_vsyn)
include $(VBOM_all:.vbom=.dep_ghdl)
include $(wildcard *.o.dep_ghdl)
endif
#
