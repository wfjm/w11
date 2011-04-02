# $Id: Makefile 351 2010-12-30 21:50:54Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2010-12-29   351   1.0    Initial version
#
VBOM_all  = $(wildcard *.vbom)
BIT_all   = $(VBOM_all:.vbom=.bit)
#
ISE_BOARD = nexys2
ISE_PATH  = xc3s1200e-fg320-4
#
.phony : all clean
#
all : $(BIT_all)
#
clean : ise_clean
	rm -f sys_tst_rlink_n2.ucf
#
sys_tst_rlink_n2.mcs : sys_tst_rlink_n2.bit
	promgen -w -x xcf04s -p mcs -u 0 sys_tst_rlink_n2
	mv sys_tst_rlink_n2.prm sys_tst_rlink_n2_prm.log
	mv sys_tst_rlink_n2.cfi sys_tst_rlink_n2_cfi.log
#
#----
#
include $(RETROBASE)/rtl/vlib/Makefile.xflow
include $(RETROBASE)/rtl/vlib/Makefile.ghdl
#
include $(VBOM_all:.vbom=.dep_xst)
include $(VBOM_all:.vbom=.dep_ghdl)
#
