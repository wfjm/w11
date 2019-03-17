# $Id: hook_ibmon_lpa.tcl 1122 2019-03-17 08:15:42Z mueller $
puts "hook: start ibmon for lpa"
package require ibd_ibmon
ibd_ibmon::stop
cpu0 cp -wibr im.lolim [cpu0 imap lpa.csr] \
        -wibr im.hilim [cpu0 imap lpa.buf]
ibd_ibmon::start
