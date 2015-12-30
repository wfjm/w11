# $Id: hook_ibmon_rka.tcl 722 2015-12-30 19:45:46Z mueller $
puts "hook: start ibmon for rka"
package require ibd_ibmon
ibd_ibmon::stop
cpu0 cp -wibr im.lolim [cpu0 imap rka.ds] \
        -wibr im.hilim [cpu0 imap rka.mr]
ibd_ibmon::start
