# $Id: defs_mmu.das 1286 2022-08-25 06:53:38Z mueller $
#
# definitions for mmu regs
#
.symbol mmr0=177572  use=%mmu.mmr0
.symbol mmr1=177574
.symbol mmr2=177576
.symbol mmr3=172516  use=%mmu.mmr3
#
000250 : v..mmu: .vect
#
# names for page descriptor & address regs a la ZKBJB0 listing
# user "I" page descriptor
.symbol uipdr0=177600  use=%mmu.pdr
.symbol uipdr1=177602  use=%mmu.pdr
.symbol uipdr2=177604  use=%mmu.pdr
.symbol uipdr3=177606  use=%mmu.pdr
.symbol uipdr4=177610  use=%mmu.pdr
.symbol uipdr5=177612  use=%mmu.pdr
.symbol uipdr6=177614  use=%mmu.pdr
.symbol uipdr7=177616  use=%mmu.pdr
# user "D" page descriptor
.symbol udpdr0=177620  use=%mmu.pdr
.symbol udpdr1=177622  use=%mmu.pdr
.symbol udpdr2=177624  use=%mmu.pdr
.symbol udpdr3=177626  use=%mmu.pdr
.symbol udpdr4=177630  use=%mmu.pdr
.symbol udpdr5=177632  use=%mmu.pdr
.symbol udpdr6=177634  use=%mmu.pdr
.symbol udpdr7=177636  use=%mmu.pdr
# user "I" page address
.symbol uipar0=177640
.symbol uipar1=177642
.symbol uipar2=177644
.symbol uipar3=177646
.symbol uipar4=177650
.symbol uipar5=177652
.symbol uipar6=177654
.symbol uipar7=177656
# user "D" page address
.symbol udpar0=177660
.symbol udpar1=177662
.symbol udpar2=177664
.symbol udpar3=177666
.symbol udpar4=177670
.symbol udpar5=177672
.symbol udpar6=177674
.symbol udpar7=177676
# supervisor "I" page descriptor
.symbol sipdr0=172200  use=%mmu.pdr
.symbol sipdr1=172202  use=%mmu.pdr
.symbol sipdr2=172204  use=%mmu.pdr
.symbol sipdr3=172206  use=%mmu.pdr
.symbol sipdr4=172210  use=%mmu.pdr
.symbol sipdr5=172212  use=%mmu.pdr
.symbol sipdr6=172214  use=%mmu.pdr
.symbol sipdr7=172216  use=%mmu.pdr
# supervisor "D" page descriptor
.symbol sdpdr0=172220  use=%mmu.pdr
.symbol sdpdr1=172222  use=%mmu.pdr
.symbol sdpdr2=172224  use=%mmu.pdr
.symbol sdpdr3=172226  use=%mmu.pdr
.symbol sdpdr4=172230  use=%mmu.pdr
.symbol sdpdr5=172232  use=%mmu.pdr
.symbol sdpdr6=172234  use=%mmu.pdr
.symbol sdpdr7=172236  use=%mmu.pdr
# supervisor "I" page address
.symbol sipar0=172240
.symbol sipar1=172242
.symbol sipar2=172244
.symbol sipar3=172246
.symbol sipar4=172250
.symbol sipar5=172252
.symbol sipar6=172254
.symbol sipar7=172256
# supervisor "D" page address
.symbol sdpar0=172260
.symbol sdpar1=172262
.symbol sdpar2=172264
.symbol sdpar3=172266
.symbol sdpar4=172270
.symbol sdpar5=172272
.symbol sdpar6=172274
.symbol sdpar7=172276
# kernel "I" page descriptor
.symbol kipdr0=172300  use=%mmu.pdr
.symbol kipdr1=172302  use=%mmu.pdr
.symbol kipdr2=172304  use=%mmu.pdr
.symbol kipdr3=172306  use=%mmu.pdr
.symbol kipdr4=172310  use=%mmu.pdr
.symbol kipdr5=172312  use=%mmu.pdr
.symbol kipdr6=172314  use=%mmu.pdr
.symbol kipdr7=172316  use=%mmu.pdr
# kernel "D" page descriptor
.symbol kdpdr0=172320  use=%mmu.pdr
.symbol kdpdr1=172322  use=%mmu.pdr
.symbol kdpdr2=172324  use=%mmu.pdr
.symbol kdpdr3=172326  use=%mmu.pdr
.symbol kdpdr4=172330  use=%mmu.pdr
.symbol kdpdr5=172332  use=%mmu.pdr
.symbol kdpdr6=172334  use=%mmu.pdr
.symbol kdpdr7=172336  use=%mmu.pdr
# kernel "I" page address
.symbol kipar0=172340
.symbol kipar1=172342
.symbol kipar2=172344
.symbol kipar3=172346
.symbol kipar4=172350
.symbol kipar5=172352
.symbol kipar6=172354
.symbol kipar7=172356
# kernel "D" page address
.symbol kdpar0=172360
.symbol kdpar1=172362
.symbol kdpar2=172364
.symbol kdpar3=172366
.symbol kdpar4=172370
.symbol kdpar5=172372
.symbol kdpar6=172374
.symbol kdpar7=172376
#
.symset %mmu.mmr0 = m0.anr=100000,\
	            m0.ale=040000,\
	            m0.ard=020000,\
	            m0.trp=010000,\
	            m0.ent=001000,\
	            m0.mai=000400,\
	            m0.ico=000200,\
		    m0.sum=000140:000140,\
		    m0.ssm=000040:000140,\
		    m0.dsp=000020,\
		    m0.sn7=000016:000016,\
		    m0.sn6=000014:000016,\
		    m0.sn5=000012:000016,\
		    m0.sn4=000010:000016,\
		    m0.sn3=000006:000016,\
		    m0.sn2=000004:000016,\
		    m0.sn1=000002:000016,\
		    m0.ena=000001
#
.symset %mmu.mmr3 = m3.eub=000040,\
	            m3.e22=000020,\
	            m3.dkm=000004,\
	            m3.dsm=000002,\
		    m3.dum=000001
#
.symset %mmu.pdr  = md.aia=000200,\
	            md.aiw=000100,\
	            md.dwn=000010,\
	            md.an7=000007:000007,\
	            md.arw=000006:000007,\
		    md.atw=000005:000007,\
	            md.atr=000004:000007,\
	            md.an3=000003:000007,\
	            md.aro=000002:000007,\
		    md.art=000001:000007
#
