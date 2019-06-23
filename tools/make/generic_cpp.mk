# $Id: generic_cpp.mk 1168 2019-06-20 11:52:51Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2011-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History: 
# Date         Rev Version  Comment
# 2018-09-22  1049   1.0.3  use -Wpedantic
# 2017-02-03   848   1.0.4  use -std=c++11 (gcc 4.7 or later)
# 2015-01-04   630   1.0.3  use -Wextra
# 2011-11-28   434   1.0.2  use -fno-strict-aliasing, avoid warn from boost bind
# 2011-11-21   432   1.0.1  gcc 4.4.5 wants explict -fPIC for .so code
# 2011-01-09   354   1.0    Initial version (from wrepo/make/generic_cxx.mk)
#---
#
# Compile options
#
# -- handle C
#   -O         optimize
#   -fPIC      position independent code
#   -Wall      all warnings
#   -Wextra    extra warnings
#   -Wpedantic pedantic warnings
#
ifdef CCCOMMAND
CC = $(CCCOMMAND)
endif
ifndef CCOPTFLAGS
CCOPTFLAGS = -O3
endif
#
CC         = gcc
CFLAGS     = -Wall -Wextra -Wpedantic -fPIC
CFLAGS    += $(CCOPTFLAGS) $(INCLFLAGS)
#
# -- handle C++
#
#   -O3      optimize
#   -fPIC    position independent code
#   -Wall    all warnings
#   -Wextra  extra warnings
#
ifdef  CXXCOMMAND
CXX = $(CXXCOMMAND)
endif
#
ifndef CXXOPTFLAGS
CXXOPTFLAGS = -O3
endif
#
CXXFLAGS   = -Wall -Wextra -Wpedantic -fPIC -fno-strict-aliasing -std=c++11 
CXXFLAGS  += $(CXXOPTFLAGS) $(INCLFLAGS)
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
