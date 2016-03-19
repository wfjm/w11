# $Id: Makefile 733 2016-02-20 12:24:13Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2014-07-27   545   1.1.1  make reference board configurable via XTW_BOARD
# 2011-08-13   405   1.1    use includes from rtl/make
# 2010-11-07   337   1.0    Initial version
#
EXE_all  = tb_dcm_sfs
#
# reference board for test synthesis is Spartan-6 based Nexys3
ifndef XTW_BOARD
  XTW_BOARD=nexys3
endif
include ${RETROBASE}/rtl/make_ise/xflow_default_$(XTW_BOARD).mk
#
.PHONY : all all_ssim all_tsim clean
#
all      : $(EXE_all)
all_ssim : $(EXE_all:=_ssim)
all_tsim : $(EXE_all:=_tsim)
#
clean : ise_clean ghdl_clean isim_clean
#
#-----
#
include ${RETROBASE}/rtl/make_ise/generic_ghdl.mk
include ${RETROBASE}/rtl/make_ise/generic_isim.mk
include ${RETROBASE}/rtl/make_ise/generic_xflow.mk
#
VBOM_all = $(wildcard *.vbom)
#
ifndef DONTINCDEP
include $(VBOM_all:.vbom=.dep_xst)
include $(VBOM_all:.vbom=.dep_ghdl)
include $(VBOM_all:.vbom=.dep_isim)
include $(wildcard *.o.dep_ghdl)
endif
#
