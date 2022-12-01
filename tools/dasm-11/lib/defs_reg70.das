# $Id: defs_reg70.das 1323 2022-12-01 08:00:41Z mueller $
#
# definitions for 11/70 cpu registers
#
.symbol cp.stk=177774
.symbol cp.pir=177772
.symbol cp.mbr=177770
.symbol cp.err=177766   use=%cp.err
.symbol cp.sid=177764
.symbol cp.his=177762
.symbol cp.los=177760
#
.symbol ms.hm=177752
.symbol ms.mai=177750
.symbol ms.ctl=177746
.symbol ms.err=177744
.symbol ms.ehi=177742
.symbol ms.elo=177740
#
.symbol cp.ubm=170200
#
.symset %cp.err = cp.hlt=000200,\
		  cp.odd=000100,\
		  cp.nxm=000040,\
		  cp.ito=000020,\
		  cp.ysv=000010,\
		  cp.rsv=000004
