# $Id: generic_cpp.mk 355 2011-01-15 09:06:23Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2011-01-09   354   1.0    Initial version (from wrepo/make/generic_cxx.mk)
#---
#
# Compile options
#
# -- handle C
#   -O      optimize
#   -fPIC   position independent code
#   -Wall   all warnings
#
#   -g      request debugging info
#
ifdef CCCOMMAND
CC = $(CCCOMMAND)
endif
ifndef CCOPTFLAGS
CCOPTFLAGS = -O
endif
#
CC         = gcc
CFLAGS     = -Wall $(CCOPTFLAGS) $(INCLFLAGS)
#
# -- handle C++
#
#   -O      optimize
#   -fPIC   position independent code
#   -Wall   all warnings
#
#   -g      request debugging info
#
ifdef  CXXCOMMAND
CXX = $(CXXCOMMAND)
endif
#
ifndef CXXOPTFLAGS
CXXOPTFLAGS = -O2
endif
#
CXXFLAGS   = -Wall -std=c++0x $(CXXOPTFLAGS) $(INCLFLAGS)
COMPILE.cc = $(CXX) $(CXXFLAGS) $(CPPFLAGS) $(TARGET_ARCH) -c
#
LINK.o     = $(CXX) $(CXXOPTFLAGS) $(LDOPTFLAGS) $(LDFLAGS) $(TARGET_ARCH)
LDFLAGS    = -g
#
# Compile rule
#
%.o: %.cpp
	$(COMPILE.cc) $< $(OUTPUT_OPTION)
#
