# $Id: Makefile 405 2011-08-14 08:16:28Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2011-08-13   405   1.1    use includes from rtl/make
# 2010-05-26   295   1.0    Initial version
#
EXE_all = tb_w11a_n2
#
ISE_PATH = xc3s1200e-fg320-4
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
