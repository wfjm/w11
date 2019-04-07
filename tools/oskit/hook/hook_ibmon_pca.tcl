# $Id: hook_ibmon_pca.tcl 1126 2019-04-06 17:37:40Z mueller $
puts "hook: start ibmon for pca"
package require ibd_ibmon
ibd_ibmon::stop
cpu0 cp -wibr im.lolim [cpu0 imap pca.rcsr] \
        -wibr im.hilim [cpu0 imap pca.pbuf]
ibd_ibmon::start
