# $Id: viv_tools_build.tcl 1242 2022-05-27 17:08:43Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2015-2022 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# Revision History:
# Date         Rev Version  Comment
# 2022-05-26  1242   1.2.5  increase message limit for Synth 8-7129
# 2018-12-30  1099   1.2.4  downgrade SSN critical warnings to warnings
# 2018-12-19  1090   1.2.3  export log and rpt generated in OOC synthesis runs
# 2018-11-18  1072   1.2.2  increase message limits (all 200, some 5000)
# 2016-09-18   809   1.2.1  keep hierarchy for synthesis only runs 
# 2016-05-22   767   1.2    cleaner setup handling; use explore flows
#                           add 2016.1 specific setups
# 2016-04-02   758   1.1.5  remove USR_ACCESS setup, must be done in xdc
# 2016-03-26   752   1.1.4  more steps supported: prj,opt,pla
# 2016-03-25   751   1.1.3  suppress some messages
# 2016-03-19   748   1.1.2  set bitstream USR_ACCESS to TIMESTAMP
# 2016-02-28   738   1.1.1  add 2015.4 specific setups
# 2015-02-21   649   1.1    add 2014.4 specific setups
# 2015-02-14   646   1.0    Initial version
#

#
# --------------------------------------------------------------------
#
proc rvtb_trace_cmd {cmd} {
  puts "# $cmd"
  eval $cmd
  return
}

#
# --------------------------------------------------------------------
#
proc rvtb_locate_setup_file {stem} {
  set name "${stem}_setup.tcl"
  if {[file readable $name]} {return $name}
  set name "$../{stem}_setup.tcl"
  if {[file readable $name]} {return $name}
  return
}

#
# --------------------------------------------------------------------
#
proc rvtb_mv_file {src dst} {
  if {[file readable $src]} {
    exec mv $src $dst
  } else {
    puts "rvtb_mv_file-W: file '$src' not existing"
  }
  return
}

#
# --------------------------------------------------------------------
#
proc rvtb_rm_file {src} {
  exec rm -f $src
}

#
# --------------------------------------------------------------------
#
proc rvtb_cp_file {src dst} {
  if {[file readable $src]} {
    exec cp -p $src $dst
  } else {
    puts "rvtb_cp_file-W: file '$src' not existing"
  }
  return
}

#
# --------------------------------------------------------------------
#
proc rvtb_build_check {step} {
  return
}

#
# --------------------------------------------------------------------
#
proc rvtb_version_is {val} {
  set vers [version -short]
  return [expr {$vers eq $val}] 
}
#
# --------------------------------------------------------------------
#
proc rvtb_version_min {val} {
  set vers [version -short]
  return [expr {[string compare $vers $val] >= 0}] 
}

#
# --------------------------------------------------------------------
#
proc rvtb_version_max {val} {
  set vers [version -short]
  return [expr {[string compare $vers $val] <= 0}] 
}

#
# --------------------------------------------------------------------
#
proc rvtb_version_in {min max} {
  set vers [version -short]
  return [expr {[string compare $vers $min] >= 0 && \
                [string compare $vers $max] <= 0}] 
}

#
# --------------------------------------------------------------------
#
proc rvtb_default_build {stem step} {
  # supported step values
  #   prj   setup project
  #   syn   run synthesis
  #   opt   run synthesis + implementation up to step opt_design
  #   pla   run synthesis + implementation up to step place_design
  #   imp   run synthesis + implementation (but not bit file generation)
  #   bit   Synthesize + Implement + generate bit file

  if {![regexp -- {^(prj|syn|opt|pla|imp|bit)$} $step]} {
    error "bad step name $step"
  }

  # general setups (prior to project creation) ------------------
  # version dependent setups 
  if {[rvtb_version_is "2014.4"]} {
    # suppress nonsense "cannot add Board Part xilinx.com:kc705..." messages
    # set here to avoid messages during create_project
    set_msg_config -suppress -id {Board 49-26} 
  }

  # read setup
  set setup_file [rvtb_locate_setup_file $stem]
  if {$setup_file ne ""} {source  -notrace $setup_file}

  # Create project ----------------------------------------------
  rvtb_trace_cmd "create_project project_mflow ./project_mflow"
  
  # Setup project properties -------------------------------
  set obj [get_projects project_mflow]
  set_property "default_lib"         "xil_defaultlib"    $obj
  set_property "part"                $::rvtb_part        $obj
  set_property "simulator_language"  "Mixed"             $obj
  set_property "target_language"     "VHDL"              $obj
  
  # general setups -----------------------------------------
  #   suppress message which don't convey useful information
  set_msg_config -suppress -id {[DRC 23-20]};       # DSP48 output pilelining
  set_msg_config -suppress -id {[Project 1-120]};   # WebTalk mandatory
  set_msg_config -suppress -id {[Common 17-186]};   # WebTalk info send
  #   set message default limit to 200 (buildin default is 100)
  set_param messaging.defaultLimit 200
  #   set message limit to 5000 for some cases
  #     Synth 8-3331 : design xxx has unconnected port yyy
  #     Synth 8-3332 : Sequential element xxx is unused .. removed from yyy
  #     Synth 8-7129 : Port xxx in module yyy is either unconnected or no load
  set_msg_config -id {[Synth 8-3331]} -limit 5000
  set_msg_config -id {[Synth 8-3332]} -limit 5000
  set_msg_config -id {[Synth 8-7129]} -limit 5000
  #   downgrade 'exceed allowable noise margins' from 'critical' to 'warnings'
  #   otherwise some MIG designs will not accepted to generate a bit file
  #   see https://www.xilinx.com/support/answers/36141.html
  set_msg_config -id {[Designutils 20-923]} -new_severity {WARNING}
  
  # Setup list of extra synthesis options (for later rodinMoreOptions)
  set synth_more_opts {}

  # version independent setups -----------------------------

  # setup synthesis strategy and options --------------
  set_property strategy Flow_PerfOptimized_high [get_runs synth_1]
  # for synthesis only: keep hierarchy for easier debug
  if {$step eq "syn"} {
    set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY none \
                 [get_runs synth_1]
  }
  # FSM recognition threshold (default is 5)
  # see http://www.xilinx.com/support/answers/58574.html
  lappend synth_more_opts {rt::set_parameter minFsmStates 3}

  # setup implementation strategy and options ---------
  set_property strategy Performance_Explore [get_runs impl_1]

  # version dependent setups -------------------------------
  if {[rvtb_version_is "2014.4"]} {
    # suppress nonsense "cannot add Board Part xilinx.com:kc705..." messages
    # repeated here because create_project apparently clears msg_config
    set_msg_config -suppress -id {Board 49-26} 
  }

  if {[rvtb_version_is "2015.4"]} {
    # enable vhdl asserts, see http://www.xilinx.com/support/answers/65415.html
    lappend synth_more_opts {rt::set_parameter ignoreVhdlAssertStmts false}
  }

  if {[rvtb_version_min "2016.1"]} {
    # enable vhdl asserts via global option (after 2016.1)
    set_property STEPS.SYNTH_DESIGN.ARGS.ASSERT true [get_runs synth_1]
  }

  # now setup extra synthesis options
  #   see http://www.xilinx.com/support/answers/58248.html
  #   -> since used via 'set_param' it's a parameter
  #   -> only last definition counts
  #   -> use ';' separated list
  #   -> these options are **NOT** preserved in project file !!
  if {[llength $synth_more_opts]} {
    puts "# extra synthesis options:"
    foreach opt $synth_more_opts { puts "#   $opt"}
    set_param synth.elaboration.rodinMoreOptions [join $synth_more_opts "; "]
  }

  # Setup filesets
  set vbom_prj [exec vbomconv -vsyn_prj "${stem}.vbom"]
  eval $vbom_prj
  update_compile_order -fileset sources_1

  if {$step eq "prj"} {
    puts "rvtb_default_build-I: new project setup for ${stem}"    
    return
  }

  # some handy variables
  set path_runs "project_mflow/project_mflow.runs"
  set path_syn1 "${path_runs}/synth_1"
  set path_imp1 "${path_runs}/impl_1"

  # build: synthesize ------------------------------------------------
  puts "# current rodinMoreOptions:"
  puts [get_param synth.elaboration.rodinMoreOptions]

  rvtb_trace_cmd "launch_runs synth_1"
  rvtb_trace_cmd "wait_on_run synth_1"

  rvtb_mv_file "$path_syn1/runme.log"  "${stem}_syn.log"
  
  rvtb_cp_file "$path_syn1/${stem}_utilization_synth.rpt" "${stem}_syn_util.rpt"
  rvtb_cp_file "$path_syn1/${stem}.dcp"                   "${stem}_syn.dcp"

  # export log and syn_util generated in OOC synthesis runs
  set ooc_dirs [glob -nocomplain -dir $path_runs -tails -type d "*_synth_1"]
  foreach ooc_dir $ooc_dirs {
    puts "# process OOC build $ooc_dir"
    set ooc_core [regsub -- {_synth_1$} $ooc_dir {}]
    rvtb_cp_file \
      "${path_runs}/${ooc_dir}/runme.log" \
      "${stem}_${ooc_core}_syn.log"
    rvtb_cp_file \
      "${path_runs}/${ooc_dir}/${ooc_core}_utilization_synth.rpt" \
      "${stem}_${ooc_core}_syn_util.rpt"
  }
  
  if {$step eq "syn"} {return [rvtb_build_check $step]}

  # build: implement -------------------------------------------------
  set launch_opt ""
  if {$step eq "opt"} {set launch_opt "-to_step opt_design"}
  if {$step eq "pla"} {set launch_opt "-to_step place_design"}

  rvtb_trace_cmd "launch_runs ${launch_opt} impl_1"
  rvtb_trace_cmd "wait_on_run impl_1"

  rvtb_cp_file "$path_imp1/runme.log"  "${stem}_imp.log"

  rvtb_cp_file "$path_imp1/${stem}_opt.dcp"           "${stem}_opt.dcp"
  rvtb_cp_file "$path_imp1/${stem}_drc_opted.rpt"     "${stem}_opt_drc.rpt"

  if {$step eq "opt"} {
    rvtb_trace_cmd "open_checkpoint $path_imp1/${stem}_opt.dcp"
    report_utilization               -file "${stem}_opt_util.rpt"
    report_utilization -hierarchical -file "${stem}_opt_util_h.rpt"
    return [rvtb_build_check $step]
  }

  rvtb_cp_file "$path_imp1/${stem}_placed.dcp"        "${stem}_pla.dcp"
  rvtb_cp_file "$path_imp1/${stem}_io_placed.rpt"     "${stem}_pla_io.rpt"
  rvtb_cp_file "$path_imp1/${stem}_utilization_placed.rpt" \
                                                      "${stem}_pla_util.rpt"
  rvtb_cp_file "$path_imp1/${stem}_control_sets_placed.rpt" \
                                                      "${stem}_pla_clk_set.rpt"

  if {$step eq "pla"} {
    return [rvtb_build_check $step]
  }

  rvtb_cp_file "$path_imp1/${stem}_routed.dcp"        "${stem}_rou.dcp"
  rvtb_cp_file "$path_imp1/${stem}_route_status.rpt"  "${stem}_rou_sta.rpt"
  rvtb_cp_file "$path_imp1/${stem}_drc_routed.rpt"    "${stem}_rou_drc.rpt"
  rvtb_cp_file "$path_imp1/${stem}_timing_summary_routed.rpt" \
                                                      "${stem}_rou_tim.rpt"
  rvtb_cp_file "$path_imp1/${stem}_power_routed.rpt"  "${stem}_rou_pwr.rpt"
  rvtb_cp_file "$path_imp1/${stem}_clock_utilization_routed.rpt" \
                                                      "${stem}_rou_clk_util.rpt"

  # additional reports
  rvtb_trace_cmd "open_run impl_1"
  report_utilization               -file "${stem}_rou_util.rpt"
  report_utilization -hierarchical -file "${stem}_rou_util_h.rpt"
  report_datasheet                 -file "${stem}_rou_ds.rpt"
  report_cdc                       -file "${stem}_rou_cdc.rpt"
  report_clock_interaction -delay_type min_max  -significant_digits 3 \
                                   -file "${stem}_rou_clk_int.rpt"
  if {[get_property SSN_REPORT [get_property PART [current_project]]]} {
    report_ssn -format TXT         -file "${stem}_rou_ssn.rpt"
  }

  if {$step eq "imp"} {return [rvtb_build_check $step]}

  # build: bitstream -------------------------------------------------
  # check for critical warnings, e.g.
  #   [Timing 38-282] The design failed to meet the timing requirements.
  # in that case abort build

  rvtb_rm_file "./${stem}.bit"

  if {[get_msg_config -severity {critical warning} -count]} {
    puts "rvtb_default_build-E: abort due to critical warnings seen before"
    puts "rvtb_default_build-E: no bitfile generated"
    return [rvtb_build_check $step]
  }

  rvtb_trace_cmd "launch_runs impl_1 -to_step write_bitstream"
  rvtb_trace_cmd "wait_on_run impl_1"

  rvtb_mv_file "$path_imp1/runme.log"     "${stem}_bit.log"
  rvtb_mv_file "$path_imp1/${stem}.bit"   "."

  return [rvtb_build_check $step]
}
