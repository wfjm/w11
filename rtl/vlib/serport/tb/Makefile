# $Id: Makefile 477 2013-01-27 14:07:10Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2011-08-13   405   1.3    use includes from rtl/make
# 2009-11-21   252   1.2    add ISim support
# 2007-11-26    98   1.1    use make includes
# 2007-06-03    48   1.0    Initial version
#
EXE_all  = tb_serport_uart_rx 
EXE_all += tb_serport_uart_rxtx 
EXE_all += tb_serport_autobaud
#
# reference board for test synthesis is Spartan-6 based Nexys3
include $(RETROBASE)/rtl/make/xflow_default_nexys3.mk
#
.PHONY : all all_ssim all_tsim clean
#
all      : $(EXE_all)
all_ssim : $(EXE_all:=_ssim)
all_tsim : $(EXE_all:=_tsim)
#
clean : ise_clean ghdl_clean isim_clean
#
#-----
#
include $(RETROBASE)/rtl/make/generic_ghdl.mk
include $(RETROBASE)/rtl/make/generic_isim.mk
include $(RETROBASE)/rtl/make/generic_xflow.mk
#
VBOM_all = $(wildcard *.vbom)
#
ifndef DONTINCDEP
include $(VBOM_all:.vbom=.dep_xst)
include $(VBOM_all:.vbom=.dep_ghdl)
include $(VBOM_all:.vbom=.dep_isim)
endif
#
