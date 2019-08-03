# $Id: util.tcl 1197 2019-07-27 10:03:21Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History: 
# Date         Rev Version  Comment
# 2019-07-13  1193   1.1    add mctest support (sv_{start,stop,load,cmd})
# 2019-06-29  1173   1.0    Initial version
# 2019-06-10  1162   0.1    First draft
#

package provide exptest_rri 1.0

array set sv_pmap {
  "tta0"   8000
  "tta1"   8001
  "dza0"   8002
  "dza1"   8003
  "dza2"   8004
  "dza3"   8005
  "dza4"   8006
  "dza5"   8007
  "dza6"   8008
  "dza7"   8009
}

set ::genv(xil_ide)  "viv";     # 'viv' is default, 'ise' alternative

#
# --------------------------------------------------------------------
#
proc sv_start {} {
  et_spawn "sv" ti_w11 $::genv(rri_opt)
  et_exp e "\ncpu0> "
  return
}

#
# --------------------------------------------------------------------
#
proc sv_stop {} {
  et_exp i $::tenv(sid_sv)
  et_exp s "\r"     e "cpu0> "
  et_exp s ".qq\r"  e eof
  et_close "sv"
  return
}

#
# --------------------------------------------------------------------
#
proc sv_load {file} {
  et_exp i $::tenv(sid_sv)
  et_exp s "cpu0 ldasm -file $file -sym ldasm_sym -lst ldasm_lst\r" e "cpu0> "
  et_exp s "cpu0 cp -stapc \$ldasm_sym(...end)\r"                   e "cpu0> "
  return
}

#
# --------------------------------------------------------------------
#
proc sv_cmd {cmd} {
  et_exp s "$cmd\r" e "cpu0> "
  return
}

#
# --------------------------------------------------------------------
#
proc sv_boot {} {
  et_spawn "sv" ti_w11 $::genv(rri_opt)
  et_exp e "\ncpu0> "
  et_exp s "source ../hook/hook_disk_over.tcl\r"   e  "\ncpu0> "
  et_exp s "@$::tenv(boot_rri)\r"                  e  "\ncpu0> "
  return
}

#
# --------------------------------------------------------------------
#
proc sv_halt {} {
  et_exp i $::tenv(sid_sv)
  et_exp t 60 e "CPU attention"
  et_exp e "rust: 01 HALTed"
  et_exp s "\r"     e "cpu0> "
  et_exp s ".qq\r"  e eof
  et_close "sv"
  return
}

#
# --------------------------------------------------------------------
#
proc sv_config {} {
  set base_conf "$::env(RETROBASE)/$::genv(sys_path)"  
  if {[catch {cd $base_conf}]} { bailout "$base_conf not existing" }

  switch -- $::genv(xil_ide) {
    viv     { sv_config_viv }
    ise     { sv_config_ise }
    default { bailout "unsuported IDE '$::genv(xil_ide)'" }
  }
  
  return
}

#
# --------------------------------------------------------------------
#
proc sv_config_viv {} {
  et_spawn "conf_tst" make -n $::opts(sys_).bit
  expect {
    "vivado" {
      bailout "$::opts(sys_).bit not existing or not up-to-date; abort"
    }
    "is up to date"  {}
    eof      { error "FAIL: make bit: unexpected 'eof' seen" }
    timeout  { error "FAIL: make bit: unexpected timeout seen" }
  }
  et_exp  e eof
  et_close "conf_tst"

  et_spawn "conf_act" make $::opts(sys_).vconfig
  et_exp t 120 e "USR_ACCESS: 0x\[0-9a-f\]+ *(\[0-9: -\]+?)" cg1 USRACC
  et_exp t  10 e eof
  et_close "conf_act"

  return
}

#
# --------------------------------------------------------------------
#
proc sv_config_ise {} {
  et_spawn "conf_tst" make -n $::opts(sys_).bit
  expect {
    "ise" {
      bailout "$::opts(sys_).bit not existing or not up-to-date; abort"
    }
    "is up to date"  {}
    eof      { error "FAIL: make bit: unexpected 'eof' seen" }
    timeout  { error "FAIL: make bit: unexpected timeout seen" }
  }
  et_exp  e eof
  et_close "conf_tst"

  et_spawn "conf_act" make $::opts(sys_).jconfig
  et_exp t 120 e "xtwi config_wrapper" 
  et_exp t  60 e eof
  et_close "conf_act"

  return
}
