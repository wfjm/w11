# $Id: Makefile 1176 2019-06-30 07:16:06Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2007-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History: 
# Date         Rev Version  Comment
# 2011-08-13   405   1.3    use includes from rtl/make
# 2010-05-23   294   1.2.1  rename tb_tst_sram -> tb_tst_sram_s3
# 2007-12-09   100   1.1    use vbom autodep
# 2007-11-19    96   1.0    Initial version
#
EXE_all  = tb_tst_sram_s3
#
include ${RETROBASE}/rtl/make_ise/xflow_default_s3board.mk
#
.PHONY : all all_ssim all_tsim clean
#
all      : $(EXE_all)
all_ssim : $(EXE_all:=_ssim)
all_tsim : $(EXE_all:=_tsim)
#
clean : ise_clean ghdl_clean
	rm -f sys_tst_sram_s3.ucf
	rm -f sys_tst_sram_simple.ucf
#
#-----
#
include ${RETROBASE}/rtl/make_ise/generic_ghdl.mk
include ${RETROBASE}/rtl/make_ise/generic_xflow.mk
#
VBOM_all = $(wildcard *.vbom)
#
ifndef DONTINCDEP
include $(VBOM_all:.vbom=.dep_xst)
include $(VBOM_all:.vbom=.dep_ghdl)
include $(wildcard *.o.dep_ghdl)
endif
#
