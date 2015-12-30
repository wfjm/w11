# $Id: hook_ibmon_rpa.tcl 722 2015-12-30 19:45:46Z mueller $
puts "hook: start ibmon for rpa"
package require ibd_ibmon
ibd_ibmon::stop
cpu0 cp -wibr im.lolim [cpu0 imap rpa.cs1] \
        -wibr im.hilim [cpu0 imap rpa.cs3]
ibd_ibmon::start
