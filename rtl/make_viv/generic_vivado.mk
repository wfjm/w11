# $Id: generic_vivado.mk 778 2016-06-25 15:18:01Z mueller $
#
# Copyright 2015-2016 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see LICENSE_gpl_v2.txt in $RETROBASE directory
#
# Revision History: 
# Date         Rev Version  Comment
# 2016-06-24   778   1.3    add rsim.vhd and [sorep]sim.v targets
# 2016-06-11   774   1.2.1  call xviv_sim_vhdl_cleanup for %_[so]sim rules
# 2016-05-27   769   1.2    add xviv_msg_filter support
# 2016-03-26   752   1.1    new %.vivado; separate %_opt.dcp,%_pla.dcp,%_rou.dcp
# 2015-02-15   646   1.0    Initial version
# 2015-01-25   637   0.1    First draft
#---
#
# check that part is defined
#
ifndef VIV_BOARD_SETUP
$(error VIV_BOARD_SETUP is not defined)
endif
#
# ensure that default tools and flows are defined
#
ifndef VIV_INIT
VIV_INIT = ${RETROBASE}/rtl/make_viv/viv_init.tcl
endif
ifndef VIV_BUILD_FLOW
VIV_BUILD_FLOW = ${RETROBASE}/rtl/make_viv/viv_default_build.tcl
endif
ifndef VIV_CONFIG_FLOW
VIV_CONFIG_FLOW = ${RETROBASE}/rtl/make_viv/viv_default_config.tcl
endif
ifndef VIV_MODEL_FLOW
VIV_MODEL_FLOW = ${RETROBASE}/rtl/make_viv/viv_default_model.tcl
endif
#
# $@ first target
# $< first dependency
# $* stem in rule match
#
# when chaining, don't delete 'expensive' intermediate files:
.SECONDARY : 
#
# Setup vivado project
#   input:   %.vbom     vbom project description
#   output:  .PHONY
#
%.vivado : %.vbom
	rm -rf project_mflow
	xtwv vivado -mode batch \
		-source ${VIV_INIT} \
		-source ${VIV_BOARD_SETUP} \
		-source ${VIV_BUILD_FLOW} \
		-tclargs $* prj
#
# Synthesize + Implement -> generate bit file
#   input:   %.vbom     vbom project description
#   output:  %.bit
#
%.bit : %.vbom
	rm -rf project_mflow
	xtwv vivado -mode batch \
		-source ${VIV_INIT} \
		-source ${VIV_BOARD_SETUP} \
		-source ${VIV_BUILD_FLOW} \
		-tclargs $* bit
	@ if [ -r $*.vmfset ]; then make $*.mfsum; fi
#
# Print log file summary
#   input:   %_*.log (not depended)
#   output:  .PHONY
%.mfsum: %.vmfset
	@ echo "=== Synthesis flow summary =================================="
	@ if [ -r $*_syn.log ]; \
	     then xviv_msg_filter syn $*.vmfset $*_syn.log; \
	     else echo "   !!! no $*_syn.log found"; fi
	@ echo "=== Implementation flow summary=============================="
	@ if [ -r $*_imp.log ]; \
	     then xviv_msg_filter imp $*.vmfset $*_imp.log; \
	     else echo "   !!! no $*_imp.log found"; fi
#
# Configure FPGA with vivado hardware server
#   input:   %.bit
#   output:  .PHONY
#
%.vconfig : %.bit
	xtwv vivado -mode batch \
		-source ${VIV_INIT} \
		-source ${VIV_BOARD_SETUP} \
		-source ${VIV_CONFIG_FLOW} \
		-tclargs $*
#
# Partial Synthesize + Implement -> generate dcp for model generation
#
# run synthesis only
%_syn.dcp : %.vbom
	rm -rf project_mflow
	xtwv vivado -mode batch \
		-source ${VIV_INIT} \
		-source ${VIV_BOARD_SETUP} \
		-source ${VIV_BUILD_FLOW} \
		-tclargs $* syn
#
# run synthesis + implementation up to step opt_design
%_opt.dcp : %.vbom
	rm -rf project_mflow
	xtwv vivado -mode batch \
		-source ${VIV_INIT} \
		-source ${VIV_BOARD_SETUP} \
		-source ${VIV_BUILD_FLOW} \
		-tclargs $* opt
#
# run synthesis + implementation up to step place_design
%_pla.dcp : %.vbom
	rm -rf project_mflow
	xtwv vivado -mode batch \
		-source ${VIV_INIT} \
		-source ${VIV_BOARD_SETUP} \
		-source ${VIV_BUILD_FLOW} \
		-tclargs $* pla
#
# run synthesis + implementation (but not bit file generation)
%_rou.dcp : %.vbom
	rm -rf project_mflow
	xtwv vivado -mode batch \
		-source ${VIV_INIT} \
		-source ${VIV_BOARD_SETUP} \
		-source ${VIV_BUILD_FLOW} \
		-tclargs $* imp
#
# Post-synthesis functional simulation model (Vhdl/Unisim)
#   input:   %_syn.dcp
#   output:  %_ssim.vhd
#
%_ssim.vhd : %_syn.dcp
	xtwv vivado -mode batch \
		-source ${VIV_INIT} \
		-source ${VIV_MODEL_FLOW} \
		-tclargs $* ssim_vhd
	xviv_sim_vhdl_cleanup $@
#
# Post-optimization functional simulation model (Vhdl/Unisim)
#   input:   %_opt.dcp
#   output:  %_osim.vhd
#
%_osim.vhd : %_opt.dcp
	xtwv vivado -mode batch \
		-source ${VIV_INIT} \
		-source ${VIV_MODEL_FLOW} \
		-tclargs $* osim_vhd
	xviv_sim_vhdl_cleanup $@
#
# Post-routing functional simulation model (Vhdl/Unisim)
#   input:   %_rou.dcp
#   output:  %_rsim.vhd
#
%_rsim.vhd : %_rou.dcp
	xtwv vivado -mode batch \
		-source ${VIV_INIT} \
		-source ${VIV_MODEL_FLOW} \
		-tclargs $* rsim_vhd
	xviv_sim_vhdl_cleanup $@
#
# Post-synthesis functional simulation model (Verilog/Unisim)
#   input:   %_syn.dcp
#   output:  %_ssim.v
#
%_ssim.v : %_syn.dcp
	xtwv vivado -mode batch \
		-source ${VIV_INIT} \
		-source ${VIV_MODEL_FLOW} \
		-tclargs $* ssim_v
#
# Post-optimization functional simulation model (Verilog/Unisim)
#   input:   %_opt.dcp
#   output:  %_osim.v
#
%_osim.v : %_opt.dcp
	xtwv vivado -mode batch \
		-source ${VIV_INIT} \
		-source ${VIV_MODEL_FLOW} \
		-tclargs $* osim_v
#
# Post-routing functional simulation model (Verilog/Unisim)
#   input:   %_rou.dcp
#   output:  %_rsim.v
#
%_rsim.v : %_rou.dcp
	xtwv vivado -mode batch \
		-source ${VIV_INIT} \
		-source ${VIV_MODEL_FLOW} \
		-tclargs $* rsim_v
#
# Post-synthesis timing simulation model (Verilog/Simprim)
#   input:   %_syn.dcp
#   output:  %_esim.v
#            %_esim.sdf
#
%_esim.v %_esim.sdf : %_syn.dcp
	xtwv vivado -mode batch \
		-source ${VIV_INIT} \
		-source ${VIV_MODEL_FLOW} \
		-tclargs $* esim_v
#
# Post-optimization timing simulation model (Verilog/Simprim)
#   input:   %_opt.dcp
#   output:  %_psim.v
#            %_psim.sdf
#
%_psim.v %_psim.sdf : %_opt.dcp
	xtwv vivado -mode batch \
		-source ${VIV_INIT} \
		-source ${VIV_MODEL_FLOW} \
		-tclargs $* psim_v
#
# Post-routing timing simulation model (Verilog/Simprim)
#   input:   %_rou.dcp
#   output:  %_tsim.v
#            %_tsim.sdf
#
%_tsim.v %_tsim.sdf : %_rou.dcp
	xtwv vivado -mode batch \
		-source ${VIV_INIT} \
		-source ${VIV_MODEL_FLOW} \
		-tclargs $* tsim_v
#
# vivado project quick starter
#
.PHONY : vivado
vivado :
	xtwv vivado -mode gui project_mflow/project_mflow.xpr

#
# generate dep_vsyn files from vbom
#
%.dep_vsyn: %.vbom
	vbomconv --dep_vsyn $< > $@

#
# Cleanup
#
include ${RETROBASE}/rtl/make_viv/dontincdep.mk
#
.PHONY : viv_clean viv_tmp_clean
#
viv_clean: viv_tmp_clean
	rm -f *.bit
	rm -f *.dcp
	rm -f *.jou
	rm -f *.log
	rm -f *.rpt
	rm -f *_[sor]sim.vhd
	rm -f *_[sorept]sim.v
	rm -f *_[ept]sim.sdf
#
viv_tmp_clean:
	rm -rf ./project_mflow
#
