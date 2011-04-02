# $Id: Makefile 372 2011-03-20 22:48:11Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2011-03-20   372   1.0.1  renamed ..tcl -> ..tpp
# 2011-03-19   371   1.0    Initial version
#---
#
# Name of the sharable library
#
SONAME     = rutiltpp
SOMAJV     = 1
SOMINV     = 0
#
# Compile and Link search paths
#
INCLFLAGS  = -I/usr/include/tcl8.4 -I${RETROBASE}/tools/src
LDLIBS     = -L${RETROBASE}/tools/lib -lrtcltools
#
# Object files to be included
#
OBJ_all    = Rutiltpp_Init.o RtclBvi.o
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
