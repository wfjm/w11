# $Id: Makefile 733 2016-02-20 12:24:13Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2011-12-11   438   1.0    Initial version
#
VBOM_all = $(wildcard *.vbom)
NGC_all  = $(VBOM_all:.vbom=.ngc)
#
include ${RETROBASE}/rtl/make_ise/xflow_default_s3board.mk
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
include ${RETROBASE}/rtl/make_ise/generic_xflow.mk
#
ifndef DONTINCDEP
include $(VBOM_all:.vbom=.dep_xst)
endif
#
