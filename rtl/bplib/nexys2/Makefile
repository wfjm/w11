# $Id: Makefile 405 2011-08-14 08:16:28Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2011-08-13   405   1.1    use includes from rtl/make
# 2010-05-23   293   1.0    Initial version (cloned..)
#
VBOM_all = $(wildcard *.vbom)
NGC_all  = $(VBOM_all:.vbom=.ngc)
#
ISE_PATH = xc3s1200e-fg320-4
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
