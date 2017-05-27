# $Id: hook_ibmon_tma.tcl 722 2015-12-30 19:45:46Z mueller $
puts "hook: start ibmon for tma"
package require ibd_ibmon
ibd_ibmon::stop
cpu0 cp -wibr im.lolim [cpu0 imap tma.sr] \
        -wibr im.hilim [cpu0 imap tma.rl]
ibd_ibmon::start
