# $Id: Makefile 477 2013-01-27 14:07:10Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2011-10-14   416   1.0    Initial version
#
VBOM_all = $(wildcard *.vbom)
NGC_all  = $(VBOM_all:.vbom=.ngc)
#
include $(RETROBASE)/rtl/make/xflow_default_s3board.mk
#
.PHONY : all clean realclean
#
all : tst_serloop
#
clean : ise_clean
#
realclean :
	rm -f tst_serloop
#
#----
#
include $(RETROBASE)/rtl/make/generic_xflow.mk
#
ifndef DONTINCDEP
include $(VBOM_all:.vbom=.dep_xst)
endif
#
