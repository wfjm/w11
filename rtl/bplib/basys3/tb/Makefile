# $Id: Makefile 1368 2023-02-07 09:18:26Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2023- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History: 
# Date         Rev Version  Comment
# 2023-02-07  1368   1.0    Initial version
#
EXE_all  = tb_basys3_dummy
#
include ${RETROBASE}/rtl/make_viv/viv_default_basys3.mk
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
