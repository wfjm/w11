# $Id: hook_ibmon_rka.tcl 899 2017-05-27 13:25:41Z mueller $
puts "hook: start ibmon for rka"
package require ibd_ibmon
ibd_ibmon::stop
cpu0 cp -wibr im.lolim [cpu0 imap rka.ds] \
        -wibr im.hilim [cpu0 imap rka.mr]
ibd_ibmon::start
