# $Id: defs_rk.das 1286 2022-08-25 06:53:38Z mueller $
#
# definitions for RK11 controller
#
000220 : v..rk: .vect
#
.symbol rk.ds  = 177400  use=%rk.ds
.symbol rk.er  = 177402  use=%rk.er
.symbol rk.cs  = 177404  use=%rk.cs
.symbol rk.wc  = 177406  use=.
.symbol rk.ba  = 177410
.symbol rk.da  = 177412
.symbol rk.mr  = 177414
.symbol rk.db  = 177416
#
.symset %rk.cs = rk.err=100000,\
                 rk.he=040000,\
	         rk.scp=020000,\
	         rk.mai=010000,\
                 rk.iba=004000,\
                 rk.fmt=002000,\
                 rk.rwa=001000,\
	         rk.sse=000400,\
                 rk.rdy=000200,\
                 rk.ie=000100,\
                 rk.fwr=000002:000016,\
                 rk.frd=000004:000016,\
                 rk.fwc=000006:000016,\
                 rk.fse=000010:000016,\
                 rk.frc=000012:000016,\
                 rk.fdr=000014:000016,\
                 rk.fwl=000016:000016,\
	         rk.go=000001
#
.symset %rk.ds = rk.id1=020000:160000,\
		 rk.id2=040000:160000,\
		 rk.id3=060000:160000,\
		 rk.id4=100000:160000,\
		 rk.id5=120000:160000,\
		 rk.id6=140000:160000,\
		 rk.id7=160000:160000,\
		 rk.dpl=010000,\
		 rk.hde=004000,\
		 rk.dru=002000,\
		 rk.sin=001000,\
		 rk.sok=000400,\
		 rk.dry=000200,\
		 rk.ary=000100,\
		 rk.wps=000040,\
		 rk.seq=000020
#
.symset %rk.er = rk.dre=100000,\
		 rk.ovr=040000,\
		 rk.wlo=020000,\
		 rk.ske=010000,\
		 rk.pce=004000,\
		 rk.nxm=002000,\
		 rk.dlt=001000,\
		 rk.rte=000400,\
		 rk.nxd=000200,\
		 rk.nxc=000100,\
		 rk.nxs=000040,\
		 rk.cse=000002,\
		 rk.wce=000001
