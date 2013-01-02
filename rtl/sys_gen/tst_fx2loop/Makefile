# $Id: Makefile 461 2012-04-09 21:17:54Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2012-02-26   458   1.1    add tst_fx2loop_si
# 2011-12-26   445   1.0    Initial version
#
VBOM_all = $(wildcard *.vbom)
NGC_all  = $(VBOM_all:.vbom=.ngc)
#
ISE_PATH = xc3s1200e-fg320-4
#
.PHONY : all clean realclean
#
all : tst_fx2loop tst_fx2loop_si
#
clean : ise_clean
#
realclean :
	rm -f tst_fx2loop tst_fx2loop_si
#
CFLAGS = -Wall -O2 -g -lusb-1.0 
#
tst_fx2loop : tst_fx2loop.c
	${CC} ${CFLAGS} -o tst_fx2loop tst_fx2loop.c
tst_fx2loop_si : tst_fx2loop_si.c
	${CC} ${CFLAGS} -o tst_fx2loop_si tst_fx2loop_si.c
#
#----
#
include $(RETROBASE)/rtl/make/generic_xflow.mk
#
include $(VBOM_all:.vbom=.dep_xst)
#
