# $Id: hook_ibmon_rpa.tcl 689 2015-06-05 14:33:18Z mueller $
puts "hook: start ibmon for rpa"
package require ibd_ibmon
ibd_ibmon::setup
ibd_ibmon::stop
cpu0 cp -wibr im.lolim [cpu0 imap rpa.cs1] \
        -wibr im.hilim [cpu0 imap rpa.cs3]
ibd_ibmon::start
