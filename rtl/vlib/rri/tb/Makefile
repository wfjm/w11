# $Id: Makefile 311 2010-06-30 17:52:37Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2009-11-21   252   1.2    add ISim support
# 2007-11-03    95   1.1.2  use .log rather .dat output in check_dsim
# 2007-09-16    83   1.1.1  add include *.o.dep_ghdl
# 2007-06-29    61   1.1    add clean and all
# 2007-06-10    51   1.0    Initial version
#
EXE_all = tb_rri_core tb_rri_serport \
	tb_rritba_ttcombo tb_rriext_ttcombo
#
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
