# $Id: hook_ibmon_tma.tcl 689 2015-06-05 14:33:18Z mueller $
puts "hook: start ibmon for tma"
package require ibd_ibmon
ibd_ibmon::setup
ibd_ibmon::stop
cpu0 cp -wibr im.lolim [cpu0 imap tma.sr] \
        -wibr im.hilim [cpu0 imap tma.rl]
ibd_ibmon::start
