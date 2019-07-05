# $Id: Makefile 1176 2019-06-30 07:16:06Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2007-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History: 
# Date         Rev Version  Comment
# 2011-08-13   405   1.4    use includes from rtl/make
# 2010-05-23   294   1.3.1  rename sys_tst_sram -> sys_tst_sram_s3
# 2010-04-24   282   1.3    use %.impact rule, all=BIT_all now
# 2010-04-17   281   1.2    targeted to sys_tst_sram
# 2007-12-20   103   1.1.2  clean rm's generated ucf files
# 2007-12-09   100   1.1.1  set ISE_PATH
# 2007-11-19    98   1.1    use auto dep
# 2007-11-19    96   1.0    Initial version
#
VBOM_all  = $(wildcard *.vbom)
BIT_all   = $(VBOM_all:.vbom=.bit)
#
include ${RETROBASE}/rtl/make_ise/xflow_default_s3board.mk
#
.PHONY : all clean
#
all : sys_tst_sram_s3.bit
#
clean : ise_clean
	rm -f $(VBOM_all:.vbom=.ucf)
#
#-----
#
include ${RETROBASE}/rtl/make_ise/generic_ghdl.mk
include ${RETROBASE}/rtl/make_ise/generic_xflow.mk
#
ifndef DONTINCDEP
include $(VBOM_all:.vbom=.dep_xst)
include $(VBOM_all:.vbom=.dep_ghdl)
endif
#
