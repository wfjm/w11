# $Id: Makefile 801 2016-08-27 16:47:01Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2016-08-26   801   1.2    use explicit VBOM_all, no wildcard
# 2011-08-13   405   1.1    use includes from rtl/make; use imp_s3_speed_maptd
# 2010-05-23   294   1.0    Initial version
#
VBOM_all  = sys_tst_sram_n2.vbom
BIT_all   = $(VBOM_all:.vbom=.bit)
#
include ${RETROBASE}/rtl/make_ise/xflow_default_nexys2.mk
XFLOWOPT_IMP = imp_s3_speed_maptd.opt
#
.PHONY : all clean
#
all : sys_tst_sram_n2.bit
#
clean : ise_clean
	rm -f $(VBOM_all:.vbom=.ucf)
#
#-----
#
include ${RETROBASE}/rtl/make_ise/generic_ghdl.mk
include ${RETROBASE}/rtl/make_ise/generic_xflow.mk
#
ifndef DONTINCDEP
include $(VBOM_all:.vbom=.dep_xst)
include $(VBOM_all:.vbom=.dep_ghdl)
endif
#
