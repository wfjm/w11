# $Id: Makefile 1176 2019-06-30 07:16:06Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2015-2016 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History: 
# Date         Rev Version  Comment
# 2016-06-18   776   1.1.1  add xsim_clean
# 2016-04-22   763   1.1    add include dep_vsim
# 2015-02-21   649   1.0    Initial version
#
EXE_all = tb_w11a_b3
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
