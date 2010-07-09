# $Id: Makefile 311 2010-06-30 17:52:37Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2010-05-28   295   1.1.4  rename sys_pdp11core -> sys_w11a_s3
# 2010-04-24   282   1.1.3  use %.impact rule, all=BIT_all now
# 2009-11-20   251   1.1.2  add .mcs rule
# 2009-07-26   236   1.1.1  add program: rule
# 2007-11-26    98   1.1    include $(RETROBASE)/vlib/Makefile.(ghdl|xflow)
# 2007-07-08    65   1.0    Initial version
#
VBOM_all  = $(wildcard *.vbom)
BIT_all   = $(VBOM_all:.vbom=.bit)
#
ISE_BOARD = s3board
ISE_PATH  = xc3s1000-ft256-4
#
.phony : all clean
#
all : $(BIT_all)
#
clean : ise_clean
	rm -f sys_w11a_s3.ucf
#
sys_w11a_s3.mcs : sys_w11a_s3.bit
	promgen -w -x xcf04s -p mcs -u 0 sys_w11a_s3
	mv sys_w11a_s3.prm sys_w11a_s3_prm.log
	mv sys_w11a_s3.cfi sys_w11a_s3_cfi.log
#
#----
#
include $(RETROBASE)/rtl/vlib/Makefile.xflow
include $(RETROBASE)/rtl/vlib/Makefile.ghdl
#
include $(VBOM_all:.vbom=.dep_xst)
include $(VBOM_all:.vbom=.dep_ghdl)
#
