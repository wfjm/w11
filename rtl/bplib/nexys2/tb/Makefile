# $Id: Makefile 467 2013-01-02 19:49:05Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2013-01-01   467   1.2.1  add tb_nexys2_fusp_cuff_dummy
# 2011-11-26   433   1.2    remove tb_n2_cram_memctl_as (moved to nxcramlib)
# 2011-08-13   405   1.1    use includes from rtl/make
# 2010-05-30   297   1.0.2  use tb_n2_cram_memctl_as now
# 2010-05-28   295   1.0.1  add tb_.._dummy's
# 2007-09-23    84   1.0    Initial version
#
EXE_all  = tb_nexys2_dummy 
EXE_all += tb_nexys2_fusp_dummy
EXE_all += tb_nexys2_fusp_cuff_dummy
#
ISE_PATH = xc3s1200e-fg320-4
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
