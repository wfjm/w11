# $Id: Makefile 405 2011-08-14 08:16:28Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2011-08-13   405   1.1    use includes from rtl/make
# 2010-12-29   351   1.0    Initial version
#
VBOM_all  = $(wildcard *.vbom)
BIT_all   = $(VBOM_all:.vbom=.bit)
#
ISE_BOARD = nexys2
ISE_PATH  = xc3s1200e-fg320-4
#
.PHONY : all clean
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
include $(RETROBASE)/rtl/make/generic_xflow.mk
include $(RETROBASE)/rtl/make/generic_ghdl.mk
#
include $(VBOM_all:.vbom=.dep_xst)
include $(VBOM_all:.vbom=.dep_ghdl)
#
