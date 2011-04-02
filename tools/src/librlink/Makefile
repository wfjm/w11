# $Id:  $
#
#  Revision History: 
# Date         Rev Version  Comment
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
INCLFLAGS  = -I${RETROBASE}/tools/src
LDLIBS     = -L${RETROBASE}/tools/lib -lrtools
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
.PHONY    : clean cleandep realclean
clean     :
	@ rm -f $(OBJ_all)
	@ echo "Object files removed"
#
cleandep  :
	@ rm -f $(DEP_all)
	@ echo "Dependency files removed"
#
realclean : clean cleandep
	@ rm -f $(SOPATH)/lib$(SONAME).a $(SOPATH)/lib$(SONAME).so*
	@ echo "Libraries removed"
#
