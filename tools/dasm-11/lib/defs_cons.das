# $Id: defs_cons.das 1286 2022-08-25 06:53:38Z mueller $
#
# definitions for console
#
000060 : v..tti: .vect
000064 : v..tto: .vect
#
.symbol ti.csr = 177560  use=%ti.cs
.symbol ti.buf = 177562
.symbol to.csr = 177564  use=%to.cs
.symbol to.buf = 177566
#
.symset %ti.cs = ti.rac=004000,\
		 ti.rdy=000200,\
		 ti.ie=000100,\
		 ti.ren=000001
.symset %to.cs = to.rdy=000200,\
		 to.ie=000100,\
		 to.mai=00004
