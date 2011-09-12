# $Id: Makefile 403 2011-08-06 17:36:22Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2011-07-31   401   1.1    rename realclean->distclean
# 2011-07-01   386   1.0.1  add BOOSTINC
# 2011-01-09   354   1.0    Initial version (adopted from CTB...)
#---
#
# Name of the sharable library
#
SONAME     = rlink
SOMAJV     = 1
SOMINV     = 0
#
# Compile and Link search paths
#
INCLFLAGS  = -I${RETROBASE}/tools/src -I${BOOSTINC}
LDLIBS     = -lboost_thread -L${RETROBASE}/tools/lib -lrtools
#
# Object files to be included
#
OBJ_all    = RlinkAddrMap.o \
             RlinkCommand.o RlinkCommandExpect.o RlinkCommandList.o \
	     RlinkConnect.o \
	     RlinkCrc8.o RlinkPacketBuf.o \
	     RlinkPort.o RlinkPortFactory.o RlinkPortFifo.o RlinkPortTerm.o
#
DEP_all    = $(OBJ_all:.o=.dep)
#
#- generic part ----------------------------------------------------------------
#
SOFILE     = lib$(SONAME).so
SOFILEV    = lib$(SONAME).so.$(SOMAJV)
SOFILEVV   = lib$(SONAME).so.$(SOMAJV).$(SOMINV)
#
include $(RETROBASE)/tools/make/generic_cpp.mk
include $(RETROBASE)/tools/make/generic_dep.mk
include $(RETROBASE)/tools/make/generic_so.mk
#
# The magic autodependcy include
#
include $(DEP_all)
#
# cleanup phonies:
#
.PHONY    : clean cleandep distclean
clean     :
	@ rm -f $(OBJ_all)
	@ echo "Object files removed"
#
cleandep  :
	@ rm -f $(DEP_all)
	@ echo "Dependency files removed"
#
distclean : clean cleandep
	@ rm -f $(SOPATH)/lib$(SONAME).a $(SOPATH)/lib$(SONAME).so*
	@ echo "Libraries removed"
#
