# $Id: viv_tools_model.tcl 792 2016-07-23 18:05:40Z mueller $
#
# Copyright 2015-2016 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see LICENSE_gpl_v2.txt in $RETROBASE directory
#
# Revision History:
# Date         Rev Version  Comment
# 2016-06-24   778   1.1    support mode [sor]sim_vhdl [sorepd]sim_veri
# 2016-06-19   777   1.0.1  use full absolute path name for sdf annotate
# 2015-02-14   646   1.0    Initial version
#
# --------------------------------------------------------------------
# supported modes
#                      base       ----- func -----      timing
#                                     vhdl    veri        veri
#  post synth       _syn.dcp      ssim_vhd  ssim_v      esim_v
#  post phys_opt    _opt.dcp      osim_vhd  osim_v      psim_v
#  post route       _rou.dcp      rsim_vhd  rsim_v      tsim_v
# 
proc rvtb_default_model {stem mode} {

  if {[regexp -- {^([sor])sim_(vhd|v)$} $mode matched type lang] || 
      [regexp -- {^([ept])sim_(v)$}     $mode matched type lang]} {

    switch $type {
      s  -
      e  {open_checkpoint "${stem}_syn.dcp"}
      o  -
      p  {open_checkpoint "${stem}_opt.dcp"}
      r  -
      t  {open_checkpoint "${stem}_rou.dcp"}
    }

    if {$lang eq "vhd"} {
      write_vhdl -mode funcsim -force "${stem}_${type}sim.vhd"
    } else {
      if {$type eq "s" || $type eq "o" || $type eq "r"} {
        write_verilog -mode funcsim -force "${stem}_${type}sim.v"
      } else {
        # use full absolute path name for sdf annotate
        # reason: the _tsim.v is sometimes generated in system path and
        #   used from the tb path. xelab doesn't find the sdf in that case
        #   Solution are absolute path (ugly) or symlink (ugly, who does setup..)
        write_verilog -mode timesim -force \
           -sdf_anno true \
           -sdf_file "[pwd]/${stem}_${type}sim.sdf" \
           "${stem}_${type}sim.v"
        write_sdf     -mode timesim -force \
           -process_corner slow \
           "${stem}_${type}sim.sdf"
      }
    }

  } else {
    error "rvtb_default_model-E: bad mode: $mode";
  }

  return "";
}
