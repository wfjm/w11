# $Id: Makefile 467 2013-01-02 19:49:05Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2013-01-01   467   1.0    Initial version
#
EXE_all = tb_tst_rlink_cuff_ic_n2
#
ISE_PATH = xc3s1200e-fg320-4
#
.PHONY : all all_ssim all_tsim clean
#
all      : $(EXE_all)
all_ssim : $(EXE_all:=_ssim)
all_tsim : $(EXE_all:=_tsim)
#
clean : ise_clean ghdl_clean
	rm -f sys_tst_rlink_cuff_ic_n2.ucf
#
#-----
#
include $(RETROBASE)/rtl/make/generic_ghdl.mk
include $(RETROBASE)/rtl/make/generic_xflow.mk
#
VBOM_all = $(wildcard *.vbom)
#
include $(VBOM_all:.vbom=.dep_xst)
include $(VBOM_all:.vbom=.dep_ghdl)
include $(wildcard *.o.dep_ghdl)
#
