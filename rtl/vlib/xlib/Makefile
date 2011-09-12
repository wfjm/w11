# $Id: Makefile 405 2011-08-14 08:16:28Z mueller $
#
#  Revision History: 
# Date         Rev Version  omment
# 2011-08-13   405   1.1    use includes from rtl/make
# 2007-12-08   100   1.0    Initial version
#
VBOM_all = $(wildcard *.vbom)
NGC_all  = $(VBOM_all:.vbom=.ngc)
#
.PHONY : all clean
#
all : $(NGC_all)
#
clean : ise_clean
#
#----
#
include $(RETROBASE)/rtl/make/generic_xflow.mk
#
include $(VBOM_all:.vbom=.dep_xst)
#
