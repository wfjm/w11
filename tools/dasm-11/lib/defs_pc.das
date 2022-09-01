# $Id: defs_pc.das 1286 2022-08-25 06:53:38Z mueller $
#
# definitions for PC11 controller
#
000070 : v..pr: .vect
000074 : v..pp: .vect
#
.symbol pr.csr = 177550  use=%pr.cs
.symbol pr.buf = 177552
.symbol pp.csr = 177554  use=%pp.cs
.symbol pp.buf = 177556
#
.symset %pr.cs = pr.err=100000,\
	         pr.bsy=004000,\
		 pr.don=000200,\
		 pr.ie=000100,\
		 pr.ena=000001
.symset %pp.cs = pp.err=100000,\
		 pp.rdy=000200,\
		 pp.ie=000100
