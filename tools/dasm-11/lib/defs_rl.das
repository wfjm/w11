# $Id: defs_rl.das 1286 2022-08-25 06:53:38Z mueller $
#
# definitions for RL11 controller
#
000160 : v..rl: .vect
#
.symbol rl.cs  = 174400  use=%rl.cs
.symbol rl.ba  = 174402
.symbol rl.da  = 174404
.symbol rl.mp  = 174406
#
.symset %rl.cs = rl.err=100000,\
                 rl.de=040000,\
	         rl.eoi=000001:036000,\
	         rl.erc=000002:036000,\
	         rl.ehc=000003:036000,\
	         rl.edl=000004:036000,\
	         rl.ehn=000005:036000,\
	         rl.enx=000010:036000,\
                 rl.cry=000200,\
                 rl.ie=000100,\
                 rl.fwc=000002:000016,\
                 rl.fgs=000004:000016,\
                 rl.fsk=000006:000016,\
                 rl.frh=000010:000016,\
                 rl.fwd=000012:000016,\
                 rl.frd=000014:000016,\
                 rl.frn=000016:000016,\
	         rl.dry=000001
#
