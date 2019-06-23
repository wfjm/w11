# $Id: generic_dep.mk 1168 2019-06-20 11:52:51Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History: 
# Date         Rev Version  Comment
# 2011-01-09   354   1.0    Initial version (from wrepo/make/generic_dep.mk)
#---
#
# Dependency generation rules
#
%.dep: %.c
	@ echo "$(CC) -MM  $< | sed ... > $@"
	@ $(SHELL) -ec '$(CC) -MM $(CPPFLAGS) $(CFLAGS) $< \
		| sed '\''s/\($*\.o\)[ :]*/\1 $@ : /g'\'' > $@'
%.dep: %.cpp
	@ echo "$(CXX) -MM  $< | sed ... > $@"
	@ $(SHELL) -ec '$(CXX) -MM $(CPPFLAGS) $(CXXFLAGS) $< \
		| sed '\''s/\($*\.o\)[ :]*/\1 $@ : /g'\'' > $@'
#
