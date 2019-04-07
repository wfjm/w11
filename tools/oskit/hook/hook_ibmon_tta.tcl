# $Id: hook_ibmon_tta.tcl 1126 2019-04-06 17:37:40Z mueller $
puts "hook: start ibmon for tta"
package require ibd_ibmon
ibd_ibmon::stop
cpu0 cp -wibr im.lolim [cpu0 imap tta.rcsr] \
        -wibr im.hilim [cpu0 imap tta.xbuf]
ibd_ibmon::start
