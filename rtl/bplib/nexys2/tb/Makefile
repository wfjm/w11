# $Id: Makefile 311 2010-06-30 17:52:37Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2010-05-30   297   1.0.2  use tb_n2_cram_memctl_as now
# 2010-05-28   295   1.0.1  add tb_.._dummy's
# 2007-09-23    84   1.0    Initial version
#
EXE_all = tb_nexys2_dummy tb_nexys2_fusp_dummy tb_n2_cram_memctl_as
#
ISE_PATH = xc3s1200e-fg320-4
#
.phony : all all_ssim all_tsim clean
#
all      : $(EXE_all)
all_ssim : $(EXE_all:=_ssim)
all_tsim : $(EXE_all:=_tsim)
#
clean : ise_clean ghdl_clean isim_clean
#
#-----
#
include $(RETROBASE)/rtl/vlib/Makefile.ghdl
include $(RETROBASE)/rtl/vlib/Makefile.isim
include $(RETROBASE)/rtl/vlib/Makefile.xflow
#
VBOM_all = $(wildcard *.vbom)
#
include $(VBOM_all:.vbom=.dep_xst)
include $(VBOM_all:.vbom=.dep_ghdl)
include $(VBOM_all:.vbom=.dep_isim)
include $(wildcard *.o.dep_ghdl)
#
