# $Id: Makefile 351 2010-12-30 21:50:54Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2010-12-30   351   1.3    retire tb_rripdp_pdp11core tb_rriext_pdp11core
# 2009-11-22   252   1.2    add ISim support
# 2007-09-16    83   1.1.1  add include *.o.dep_ghdl
# 2007-07-06    64   1.1    use vbom's
# 2007-06-17    58   1.0    Initial version
#
EXE_all = tb_pdp11core tb_rlink_tba_pdp11core
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
#-----
#  	time ~/misc_walter/p11_util/bin/pdp11 $*.scmd > $*.simh_raw_log
%.simh_log: %.dat
	tbdat2simh $*.dat > $*.scmd
	time pdp11 $*.scmd > $*.simh_raw_log
	simdat_check $*.simh_raw_log > $*.simh_log
	grep FAIL  $*.simh_log

check_dsim: tb_pdp11core tb_pdp11core_stim.dat
	time tbw tb_pdp11core |\
	   tee tb_pdp11core_dsim.log |\
	   egrep "(FAIL|DONE)" || true
	@ echo "# diff to reference"
	diff tb_pdp11core_out_ref.dat tb_pdp11core_dsim.log

check_ssim: tb_pdp11core_ssim tb_pdp11core_stim.dat
	time tbw tb_pdp11core_ssim |\
	   tee tb_pdp11core_ssim.log |\
	   egrep "(FAIL|DONE)" || true
	@ echo "# diff to reference"
	diff tb_pdp11core_out_ref.dat tb_pdp11core_ssim.log

check_simh: tb_pdp11core_stim.simh_log
