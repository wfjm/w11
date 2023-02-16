# $Id: 211bsd_eth.tcl 1373 2023-02-16 11:21:26Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2019-2023 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History: 
# Date         Rev Version  Comment
# 2023-02-14  1373   1.1.1  use 'ip -j -p a' to probe tap0 existence
# 2019-07-20  1196   1.1    Use os namespace 211bsd
# 2019-06-29  1173   1.0    Initial version
# 2019-06-10  1163   0.1    First draft
#---
# basic procs for 211bsd eth tests
#

set ::tenv(ip_addr) "192.168.178.150";  # w11 system ip address

namespace eval 211bsd {
  #
  # ------------------------------------------------------------------
  #
  lappend ::tenv(procs_preboot) "211bsd::eth_preboot"
  proc eth_preboot {} {
    et_spawn "if_tst" "ip" "-j" "-p" "a"
    set rc 1
    expect {
      -re {"ifname": "tap0"} { set rc 0; exp_continue}
      eof              { }
    }
    et_close "if_tst"
    
    if ($rc) { puts "-I: 'tap0' device required but not available" }
    
    return $rc
  }
  
  #
  # ------------------------------------------------------------------
  #
  lappend ::tenv(procs_test) "211bsd::eth_test_basic"
  proc eth_test_basic {} {
    et_spawn "pty0" telnet $::tenv(ip_addr)
    et_exp e "Trying"
    et_exp e "Connected to"
    et_exp e "Escape character is"
    et_exp e "2.11 BSD UNIX"
    et_exp e "login: "   s "root\r"
    et_exp e $::tenv(os_kpr)
    et_exp s "ps -aux\r"
    et_exp e "telnetd"
    et_exp e $::tenv(os_kpr)
    et_exp s "who\r"
    et_exp e "root +ttyp"
    et_exp e $::tenv(os_kpr)
    et_exp s "\004"
    et_exp e "Connection closed by foreign host"
    et_exp e eof
    et_close "pty0"
    return
  }

}

