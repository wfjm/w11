# $Id: defs_iist.das 1286 2022-08-25 06:53:38Z mueller $
#
# definitions for IIST controler
#
000260 : v..iis: .vect
#
.symbol ii.acr = 177500  use=%ii.acr
.symbol ii.adr = 177502
#
.symset %ii.acr = ii.clr=100000,\
                  ii.si1=000400:001400,\
                  ii.si2=001000:001400,\
                  ii.si3=001400:001400,\
                  ii.pge=000000:000017,\
                  ii.pgc=000001:000017,\
                  ii.ste=000002:000017,\
                  ii.stc=000003:000017,\
                  ii.msk=000004:000017,\
                  ii.pgf=000005:000017,\
                  ii.stf=000006:000017,\
                  ii.dcf=000007:000017,\
                  ii.exc=000010:000017,\
                  ii.mtc=000015:000017
#
.symset %ii.pgc = ii.err=100000,\
		  ii.grj=040000,\
		  ii.pgr=020000,\
		  ii.str=010000,\
		  ii.rdy=004000,\
		  ii.ip=000010,\
		  ii.ie=000004,\
		  ii.ptp=000002,\
		  ii.go=000001
#
.symset %ii.stc = ii.tmo=000010,\
		  ii.lke=000004,\
		  ii.stp=000002,\
		  ii.enb=000001
#
.symset %ii.mtc = ii.mtp=004000,\
		  ii.mfr=002000,\
                  ii.mi1=000400:001400,\
                  ii.mi2=001000:001400,\
                  ii.mi3=001400:001400,\
		  ii.dbt=000010,\
		  ii.mxd=000004,\
	          ii.mlp=000002,\
		  ii.ddr=000001
