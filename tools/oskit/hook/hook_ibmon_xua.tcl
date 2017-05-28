# $Id: hook_ibmon_xua.tcl 901 2017-05-28 11:26:11Z mueller $
puts "hook: start ibmon for xua"

# set filter on xua registers
# repeat collapse for reads (211bsd driver does polling!)

.imd
.imf xua.pr0 xua.pr3
.ime R
