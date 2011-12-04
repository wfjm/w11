# $Id: Makefile 433 2011-11-27 22:04:39Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2011-11-26   432   1.0    Initial version
#
EXE_all = tb_nexys3_fusp_dummy 
#
ISE_PATH  = xc6slx16-csg324-2
#
XFLOWOPT_SYN = syn_s6_speed.opt
XFLOWOPT_IMP = imp_s6_speed.opt
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
