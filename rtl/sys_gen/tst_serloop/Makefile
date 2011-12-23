# $Id: Makefile 441 2011-12-20 17:01:16Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2011-10-14   416   1.0    Initial version
#
VBOM_all = $(wildcard *.vbom)
NGC_all  = $(VBOM_all:.vbom=.ngc)
#
ISE_PATH = xc3s1000-ft256-4
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
include $(VBOM_all:.vbom=.dep_xst)
#
