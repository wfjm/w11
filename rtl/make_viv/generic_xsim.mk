# $Id: generic_xsim.mk 778 2016-06-25 15:18:01Z mueller $
#
# Copyright 2016- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see LICENSE_gpl_v2.txt in $RETROBASE directory
#
#  Revision History: 
# Date         Rev Version  Comment
# 2016-06-24   778   1.1    add [rep]sim models; use xsim.?sim as workdir
# 2016-02-06   727   1.0    Initial version
#
%_XSim : %.vbom
	vbomconv -vsim_prj $< > $*_vsim.sh
	chmod +x $*_vsim.sh
	$*_vsim.sh
	rm -rf $*_vsim.sh
#
# rule to build XSim ssim model from _ssim vbom (post synth, functional)
#
%_XSim_ssim : %_ssim.vbom
	vbomconv -vsim_prj $< > $*_vsim.sh
	chmod +x $*_vsim.sh
	$*_vsim.sh
	rm -rf $*_vsim.sh
#
# rule to build XSim osim model from _ssim vbom (post opt, functional)
#
%_XSim_osim : %_ssim.vbom
	vbomconv -vsim_prj $*_osim.vbom > $*_vsim.sh
	chmod +x $*_vsim.sh
	$*_vsim.sh
	rm -rf $*_vsim.sh
#
# rule to build XSim rsim model from _ssim vbom (post route, functional)
#
%_XSim_rsim : %_ssim.vbom
	vbomconv -vsim_prj $*_rsim.vbom > $*_vsim.sh
	chmod +x $*_vsim.sh
	$*_vsim.sh
	rm -rf $*_vsim.sh
#
# rule to build XSim esim model from _ssim vbom (post synth, timing)
#
%_XSim_esim : %_ssim.vbom
	vbomconv -vsim_prj $*_esim.vbom > $*_vsim.sh
	chmod +x $*_vsim.sh
	$*_vsim.sh
	rm -rf $*_vsim.sh
#
# rule to build XSim psim model from _ssim vbom (post opt, timing)
#
%_XSim_psim : %_ssim.vbom
	vbomconv -vsim_prj $*_psim.vbom > $*_vsim.sh
	chmod +x $*_vsim.sh
	$*_vsim.sh
	rm -rf $*_vsim.sh
#
# rule to build XSim tsim model from _ssim vbom (post rou, timing)
#
%_XSim_tsim : %_ssim.vbom
	vbomconv -vsim_prj $*_tsim.vbom > $*_vsim.sh
	chmod +x $*_vsim.sh
	$*_vsim.sh
	rm -rf $*_vsim.sh
#
%.dep_vsim: %.vbom
	vbomconv --dep_vsim $< > $@
#
include ${RETROBASE}/rtl/make_ise/dontincdep.mk
#
.PHONY: xsim_clean xsim_tmp_clean
#
xsim_clean: xsim_tmp_clean
	rm -f $(EXE_all:%=%_XSim)
	rm -f $(EXE_all:%=%_XSim_ssim)
	rm -f $(EXE_all:%=%_XSim_osim)
	rm -f $(EXE_all:%=%_XSim_rsim)
	rm -f $(EXE_all:%=%_XSim_esim)
	rm -f $(EXE_all:%=%_XSim_psim)
	rm -f $(EXE_all:%=%_XSim_tsim)
	rm -rf xsim.[bsorept]sim 
#
xsim_tmp_clean:
	rm -f *.wdb
	rm -f xsim.jou xsim_*.backup.jou
	rm -f xsim.log xsim_*.backup.log
	rm -f webtalk.jou webtalk_*.backup.jou
	rm -f webtalk.log webtalk_*.backup.log
	rm -rf xsim.[bsorept]sim/xsim.dir/xil_defaultlib
	rm -f xsim.dir
#
