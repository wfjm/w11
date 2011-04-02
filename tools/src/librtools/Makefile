# $Id: Makefile 374 2011-03-27 17:02:47Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2011-03-27   374   1.0.1  removed Rnamed (obsolete now)
# 2011-01-15   357   1.0    Initial version (adopted from CTB...)
#---
#
# Name of the sharable library
#
SONAME     = rtools
SOMAJV     = 1
SOMINV     = 0
#
# Compile and Link search paths
#
INCLFLAGS  = 
LDLIBS     = 
#
# Object files to be included
#
OBJ_all    = RerrMsg.o RosFill.o RosPrintBvi.o RosPrintfBase.o RosPrintfS.o \
	     RiosState.o \
             RlogFile.o RlogStd.o \
             Rstats.o Rtools.o
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
