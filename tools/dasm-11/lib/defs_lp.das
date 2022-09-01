# $Id: defs_lp.das 1286 2022-08-25 06:53:38Z mueller $
#
# definitions for lp11
#
# definition of vector excluded because it
# collides with startup code of normal xxdp diags
#
# 000200 : v..lp: .vect
#
.symbol lp.csr = 177514  use=%lp.cs
.symbol lp.buf = 177516
#
.symset %lp.cs = lp.err=100000,\
                 lp.don=000200,\
		 lp.ie=000100
