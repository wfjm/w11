# $Id: hook_ibmon_xua.tcl 899 2017-05-27 13:25:41Z mueller $
puts "hook: start ibmon for xua"
package require ibd_ibmon
ibd_ibmon::stop
cpu0 cp -wibr im.lolim [cpu0 imap xua.pr0] \
        -wibr im.hilim [cpu0 imap xua.pr3]
#ibd_ibmon::start cpu0 wena 0
ibd_ibmon::start
