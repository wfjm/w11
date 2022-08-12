# $Id: Makefile 1275 2022-08-10 08:10:40Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2022- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History: 
# Date         Rev Version  Comment
# 2022-08-08  1275   1.1    add auto-dependency rule
# 2022-07-29  1264   1.0    Initial version
#---
#
include ${RETROBASE}/tools/make/generic_asm11.mk
include ${RETROBASE}/tools/make/dontincdep.mk
#
MAC_all += cpu_badinst_nofpp.mac
MAC_all += cpu_basics.mac
MAC_all += cpu_details.mac
MAC_all += cpu_eis.mac
MAC_all += cpu_mmu.mac
MAC_all += cpu_selftest.mac
#
LDA_all  = $(MAC_all:.mac=.lda)
LST_all  = $(MAC_all:.mac=.lst)
EXP_all  = $(MAC_all:.mac=.exp.mac)
TSIM_all = $(MAC_all:.mac=.tsim)
TE11_all = $(MAC_all:.mac=.te11)
TW11_all = $(MAC_all:.mac=.tw11)
#
DEP_all  = $(MAC_all:.mac=.dep)
#
# create export mac (with asm-11 -E)
%.exp.mac : %.mac
	asm-11 -E $< > $@
# execute SimH simulation
%.tsim : %.lda
	pdp11 tcode_exec.scmd $* | grep -q "HALT instruction, PC: 002002"
# execute e11 simulation; output goes to tmp_e11_tt0.log
%.te11 : %.lda
	@rm -f tmp_e11.ini
	@echo "@tcode.ecmd" >> tmp_e11.ini
	@echo "mount pr: $*.lda" >> tmp_e11.ini
	@echo "boot pr:" >> tmp_e11.ini
	@echo "quit" >> tmp_e11.ini
	e11 /initfile:tmp_e11.ini
	grep "PC/002002" tmp_e11_tt0.log
	rm -f tmp_e11_tt0.log tmp_e11.ini
# execute w11 simulation (on C7 system)
%.tw11 : %.mac
	ti_w11 -c7 -tmu -w -e $< | tbfilt
#
.PHONY : default alllda alllst allexp alltsim alltw11 clean
#
default :
	@echo "No default action defined, use"
	@echo "  make alllda           all .lda + .lst files"
	@echo "  make alllst           all .lst files"
	@echo "  make allexp           all exp.mac export files"
	@echo "  make alltsim          all SimH tests"
	@echo "  make allte11          all e11 tests"
	@echo "  make alltw11          all w11 GHDL simulation tests"
	@echo "  make <tcode>.lda      compile, create .lda + .lst"
	@echo "  make <tcode>.lst      compile, create .lst"
	@echo "  make <tcode>.exp.mac  compile with -E"
	@echo "  make <tcode>.tsim     run SimH simulator"
	@echo "  make <tcode>.te11     run e11  simulator"
	@echo "  make <tcode>.tw11     run w11  GHDL simulation (for C7)"
#
alllda : $(LDA_all)
#
alllst : $(LST_all)
#
allexp : $(EXP_all)
#
alltsim : $(TSIM_all)
#
allte11 : $(TE11_all)
#
alltw11 : $(TW11_all)
#
clean :
	rm -f *.lst
	rm -f *.lda
	rm -f *.exp.mac
#
cleandep :
	rm -f *.dep
#
distclean : clean cleandep


# The magic auto-dependency include
#
ifndef DONTINCDEP
include $(DEP_all)
endif
