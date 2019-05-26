# $Id: hook_ibmon_dza.tcl 1149 2019-05-12 21:00:29Z mueller $
puts "hook: start ibmon for dza"
package require ibd_ibmon
ibd_ibmon::stop
cpu0 cp -wibr im.lolim [cpu0 imap dza.csr] \
        -wibr im.hilim [cpu0 imap dza.tdr]
ibd_ibmon::start
