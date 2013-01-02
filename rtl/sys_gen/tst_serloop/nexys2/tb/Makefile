# $Id: Makefile 448 2012-01-02 21:55:11Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2011-11-13   424   1.0    Initial version
#
EXE_all  = tb_tst_serloop1_n2
EXE_all += tb_tst_serloop2_n2
#
ISE_BOARD = nexys2
ISE_PATH  = xc3s1200e-fg320-4
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
include $(RETROBASE)/rtl/make/generic_ghdl.mk
include $(RETROBASE)/rtl/make/generic_isim.mk
include $(RETROBASE)/rtl/make/generic_xflow.mk
#
VBOM_all = $(wildcard *.vbom)
#
include $(VBOM_all:.vbom=.dep_xst)
include $(VBOM_all:.vbom=.dep_ghdl)
include $(VBOM_all:.vbom=.dep_isim)
include $(wildcard *.o.dep_ghdl)
#
