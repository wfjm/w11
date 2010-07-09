# $Id: Makefile 311 2010-06-30 17:52:37Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2010-05-26   295   1.0    Initial version
#
EXE_all = tb_w11a_n2
#
ISE_PATH = xc3s1200e-fg320-4
#
#
.phony : all all_ssim all_tsim clean
#
all      : $(EXE_all)
all_ssim : $(EXE_all:=_ssim)
all_tsim : $(EXE_all:=_tsim)
#
clean : ise_clean ghdl_clean
#
#-----
#
include $(RETROBASE)/rtl/vlib/Makefile.ghdl
include $(RETROBASE)/rtl/vlib/Makefile.xflow
#
VBOM_all = $(wildcard *.vbom)
#
include $(VBOM_all:.vbom=.dep_xst)
include $(VBOM_all:.vbom=.dep_ghdl)
include $(wildcard *.o.dep_ghdl)
#
