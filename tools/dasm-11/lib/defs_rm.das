# $Id: defs_rm.das 1286 2022-08-25 06:53:38Z mueller $
#
# definitions for RH70 + RM disk controller
#
000254 : v..rm: .vect
#
.symbol rm.cs1 = 176700  use=%rm.cs1
.symbol rm.wc  = 176702  use=.
.symbol rm.ba  = 176704
.symbol rm.da  = 176706
.symbol rm.cs2 = 176710
.symbol rm.ds  = 176712
.symbol rm.er1 = 176714  use=%rm.er1
.symbol rm.as  = 176716
.symbol rm.la  = 176720
.symbol rm.db  = 176722
.symbol rm.mr1 = 176724
.symbol rm.dt  = 176726
.symbol rm.sn  = 176730
.symbol rm.of  = 176732
.symbol rm.dc  = 176734
.symbol rm.hr  = 176736
.symbol rm.mr2 = 176740
.symbol rm.er2 = 176742
.symbol rm.ec1 = 176744
.symbol rm.ec2 = 176746
.symbol rm.bae = 176750
.symbol rm.cs3 = 176752
#
# cs1 symset incomplete
.symset %rm.cs1= rm.sc=100000,\
                 rm.tre=040000,\
                 rm.dva=004000,\
                 rm.rdy=000200,\
                 rm.ie=000100,\
                 rm.fsk=000004:000016,\
                 rm.fcl=000010:000016,\
	         rm.go=000001
# 
.symset %rm.er1= rm.dck=100000,\
                 rm.uns=040000,\
                 rm.opi=020000,\
                 rm.dte=010000,\
                 rm.wle=004000,\
                 rm.iae=002000,\
                 rm.aoe=001000,\
                 rm.hcr=000400,\
                 rm.hce=000200,\
                 rm.ech=000100,\
                 rm.wcf=000040,\
                 rm.fer=000020,\
                 rm.par=000010,\
                 rm.rmr=000004,\
                 rm.ilr=000002,\
                 rm.ilf=000001
