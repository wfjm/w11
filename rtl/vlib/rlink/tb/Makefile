# $Id: Makefile 349 2010-12-28 14:02:13Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2010-12-28   349   1.3.1  add tb_rlink_tba_eyemon
# 2010-12-05   343   1.3    rri->rlink renames
# 2009-11-21   252   1.2    add ISim support
# 2007-11-03    95   1.1.2  use .log rather .dat output in check_dsim
# 2007-09-16    83   1.1.1  add include *.o.dep_ghdl
# 2007-06-29    61   1.1    add clean and all
# 2007-06-10    51   1.0    Initial version
#
EXE_all = tb_rlink_direct tb_rlink_serport \
            tb_rlink_tba_ttcombo tb_rlink_tba_eyemon
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
