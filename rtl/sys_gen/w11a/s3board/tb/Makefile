# $Id: Makefile 311 2010-06-30 17:52:37Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2010-05-26   295   1.2    rename tb_s3board_pdp11core -> tb_w11a_s3
# 2007-11-26    98   1.1    add all_ssim and all_tsim targets
# 2007-09-23    84   1.0    Initial version
#
EXE_all = tb_w11a_s3
#
ISE_PATH = xc3s1000-ft256-4
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
