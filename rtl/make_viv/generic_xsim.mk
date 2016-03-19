# $Id: generic_xsim.mk 733 2016-02-20 12:24:13Z mueller $
#
# Copyright 2016- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see LICENSE_gpl_v2.txt in $RETROBASE directory
#
#  Revision History: 
# Date         Rev Version  Comment
# 2016-02-06   727   1.0    Initial version
#
%_XSim : %.vbom
	vbomconv -vsim_prj $< > $*_vsim.sh
	chmod +x $*_vsim.sh
	$*_vsim.sh
	rm -rf $*_vsim.sh
#
# rule to build XSim ssim model from _ssim vbom
#
%_XSim_ssim : %_ssim.vbom
	vbomconv -vsim_prj $< > $*_vsim.sh
	chmod +x $*_vsim.sh
	$*_vsim.sh
	rm -rf $*_vsim.sh
#
# rule to build XSim osim model from _ssim vbom
#
%_XSim_osim : %_ssim.vbom
	vbomconv -vsim_prj $*_osim.vbom > $*_vsim.sh
	chmod +x $*_vsim.sh
	$*_vsim.sh
	rm -rf $*_vsim.sh
#
# rule to build XSim tsim model from _ssim vbom
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
	rm -f $(EXE_all:%=%_XSim_tsim)
#
xsim_tmp_clean:
	rm -f isim.log isim.wdb
	rm -f xsim.jou xsim.log
	rm -f xsim_*.backup.jou xsim_*.backup.log
	rm -f webtalk.jou webtalk.log
	rm -f webtalk_*.backup.jou webtalk_*.backup.log
	rm -rf xsim.dir
#
