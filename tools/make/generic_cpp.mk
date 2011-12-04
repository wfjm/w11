# $Id: generic_cpp.mk 434 2011-12-02 19:17:38Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2011-11-28   434   1.0.2  use -fno-strict-aliasing to avoid warings from boost bind
# 2011-11-21   432   1.0.1  gcc 4.4.5 wants explict -fPIC for .so code
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
CFLAGS     = -Wall -fPIC $(CCOPTFLAGS) $(INCLFLAGS)
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
CXXFLAGS   = -Wall -fPIC -fno-strict-aliasing -std=c++0x $(CXXOPTFLAGS) $(INCLFLAGS)
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
