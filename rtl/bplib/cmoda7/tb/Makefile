# $Id: Makefile 912 2017-06-11 18:30:03Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2017-06-11   912   1.1    add tb_c7_sram_memctl
# 2017-06-04   906   1.0    Initial version
#
EXE_all  = tb_cmoda7_dummy
EXE_all += tb_cmoda7_sram_dummy 
EXE_all += tb_c7_sram_memctl
#
include ${RETROBASE}/rtl/make_viv/viv_default_cmoda7.mk
#
.PHONY : all all_ssim all_osim clean
.PHONY : all_XSim all_XSim_ssim all_XSim_osim all_XSim_tsim 
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
clean : viv_clean ghdl_clean xsim_clean
#
#-----
#
include ${RETROBASE}/rtl/make_viv/generic_ghdl.mk
include ${RETROBASE}/rtl/make_viv/generic_xsim.mk
include ${RETROBASE}/rtl/make_viv/generic_vivado.mk
#
VBOM_all = $(wildcard *.vbom)
#
ifndef DONTINCDEP
include $(VBOM_all:.vbom=.dep_vsyn)
include $(VBOM_all:.vbom=.dep_ghdl)
include $(VBOM_all:.vbom=.dep_vsim)
include $(wildcard *.o.dep_ghdl)
endif
#
