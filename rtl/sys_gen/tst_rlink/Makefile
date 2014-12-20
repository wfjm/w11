# $Id: Makefile 602 2014-11-08 21:42:47Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2011-12-11   438   1.0    Initial version
#
VBOM_all = $(wildcard *.vbom)
NGC_all  = $(VBOM_all:.vbom=.ngc)
#
include $(RETROBASE)/rtl/make/xflow_default_s3board.mk
#
.PHONY : all clean
#
all : $(NGC_all)
#
clean : ise_clean
#
#
#----
#
include $(RETROBASE)/tools/make/dontincdep.mk
include $(RETROBASE)/rtl/make/generic_xflow.mk
#
ifndef DONTINCDEP
include $(VBOM_all:.vbom=.dep_xst)
endif
#
