# $Id: hook_ibmon_tma.tcl 899 2017-05-27 13:25:41Z mueller $
puts "hook: start ibmon for tma"
package require ibd_ibmon
ibd_ibmon::stop
cpu0 cp -wibr im.lolim [cpu0 imap tma.sr] \
        -wibr im.hilim [cpu0 imap tma.rl]
ibd_ibmon::start
