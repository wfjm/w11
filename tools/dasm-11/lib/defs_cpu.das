# $Id: defs_cpu.das 1286 2022-08-25 06:53:38Z mueller $
#
# definitions for cpu
#
.symbol cp.psw = 177776   use=%cp.psw
.symbol cp.dsr = 177570   use=%bits
.symbol xor.cs = 177060
#
.symset %cp.psw = cp.cms=040000:140000,\
	          cp.cmu=140000:140000,\
	          cp.pms=010000:030000,\
	          cp.pmu=030000:030000,\
	          cp.ars=004000,\
	          cp.pr0=000000:000340,\
	          cp.pr1=000040:000340,\
	          cp.pr2=000100:000340,\
	          cp.pr3=000140:000340,\
	          cp.pr4=000200:000340,\
	          cp.pr5=000240:000340,\
	          cp.pr6=000300:000340,\
	          cp.pr7=000340:000340,\
                  cp.t=000020,\
                  cp.n=000010,\
                  cp.z=000004,\
                  cp.v=000002,\
                  cp.c=000001
#
@defs_bits.das
#
