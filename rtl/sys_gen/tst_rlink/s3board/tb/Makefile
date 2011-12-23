# $Id: Makefile 442 2011-12-23 10:03:28Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2011-12-22   442   1.0    Initial version
#
EXE_all = tb_tst_rlink_s3
#
ISE_PATH = xc3s1000-ft256-4
#
.PHONY : all all_ssim all_tsim clean
#
all      : $(EXE_all)
all_ssim : $(EXE_all:=_ssim)
all_tsim : $(EXE_all:=_tsim)
#
clean : ise_clean ghdl_clean
	rm -f sys_tst_rlink_s3.ucf
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
