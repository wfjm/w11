# $Id: hook_ibmon_rpa.tcl 899 2017-05-27 13:25:41Z mueller $
puts "hook: start ibmon for rpa"
package require ibd_ibmon
ibd_ibmon::stop
cpu0 cp -wibr im.lolim [cpu0 imap rpa.cs1] \
        -wibr im.hilim [cpu0 imap rpa.cs3]
ibd_ibmon::start
