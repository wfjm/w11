# $Id: generic_ghdl.mk 830 2016-12-26 20:25:49Z mueller $
#
# Copyright 2015-2016 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see License.txt in $RETROBASE directory
#
#  Revision History: 
# Date         Rev Version  Comment
# 2016-07-01   781   1.1.1  ghdl_clean: remove also gcov files
# 2016-06-24   778   1.1    add rsim model; use ghdl.?sim as workdir
# 2015-02-14   646   1.0    Initial version (cloned from make_ise)
#
GHDLIEEE    = --ieee=synopsys
GHDLXLPATH  = ${XTWV_PATH}/ghdl
#
% : %.vbom
	vbomconv --ghdl_i $<
	vbomconv --ghdl_m --xlpath=$(GHDLXLPATH) $<
#
# rules for _[or]sim to use 'virtual' [or]sim vbom's  (derived from _ssim)
#
%_osim : %_ssim.vbom
	vbomconv --ghdl_i $*_osim.vbom
	vbomconv --ghdl_m --xlpath=$(GHDLXLPATH) $*_osim.vbom
#
%_rsim : %_ssim.vbom
	vbomconv --ghdl_i $*_rsim.vbom
	vbomconv --ghdl_m --xlpath=$(GHDLXLPATH) $*_rsim.vbom
#
%.dep_ghdl: %.vbom
	vbomconv --dep_ghdl $< > $@
#
include ${RETROBASE}/rtl/make_ise/dontincdep.mk
#
.PHONY: ghdl_clean ghdl_tmp_clean
#
ghdl_clean: ghdl_tmp_clean
	rm -f $(EXE_all)
	rm -f $(EXE_all:%=%_[sor]sim)
	rm -f *.gcov *.gcda *.gcno
#
ghdl_tmp_clean:
	rm -rf ghdl.[bsor]sim
	rm -f cext_*.o e~*.o
#
