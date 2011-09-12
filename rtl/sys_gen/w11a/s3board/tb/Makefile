# $Id: Makefile 405 2011-08-14 08:16:28Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2011-08-13   405   1.3    use includes from rtl/make
# 2010-05-26   295   1.2    rename tb_s3board_pdp11core -> tb_w11a_s3
# 2007-11-26    98   1.1    add all_ssim and all_tsim targets
# 2007-09-23    84   1.0    Initial version
#
EXE_all = tb_w11a_s3
#
ISE_PATH = xc3s1000-ft256-4
#
#
.PHONY : all all_ssim all_tsim clean
#
all      : $(EXE_all)
all_ssim : $(EXE_all:=_ssim)
all_tsim : $(EXE_all:=_tsim)
#
clean : ise_clean ghdl_clean
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
