# $Id: defs_kwp.das 1286 2022-08-25 06:53:38Z mueller $
#
# definitions for kw11-p (programmable clock)
#
000104 : v..kwp: .vect
#
.symbol kp.csr = 172540  use=%kp.cs
.symbol kp.buf = 172542
.symbol kp.cnt = 172544
#
.symset %kp.cs = kp.err=100000,\
		 kp.don=000200,\
		 kp.ie=000100,\
		 kp.fix=000040,\
		 kp.up=000020,\
		 kp.rep=000010,\
		 kp.rex=000006:000006,\
		 kp.rlf=000004:000006,\
		 kp.rtk=000002:000006,\
		 kp.run=000001
