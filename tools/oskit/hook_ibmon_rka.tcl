# $Id: hook_ibmon_rka.tcl 690 2015-06-07 18:23:51Z mueller $
puts "hook: start ibmon for rka"
package require ibd_ibmon
ibd_ibmon::setup
ibd_ibmon::stop
cpu0 cp -wibr im.lolim [cpu0 imap rka.ds] \
        -wibr im.hilim [cpu0 imap rka.mr]
ibd_ibmon::start
