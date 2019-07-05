# $Id: Makefile 1176 2019-06-30 07:16:06Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History: 
# 2019-05-19  1151   1.0.1  add dz11
# 2019-05-07  1147   1.0    Initial version
#
DIRS  = dl11
DIRS += dz11
DIRS += lp11
DIRS += m9312
DIRS += pc11
DIRS += sys
#
TARGETS = all alllda allcof alllst clean
#
.PHONY: $(TARGETS) $(DIRS)
#
$(TARGETS): $(DIRS)
#
$(DIRS):
	$(MAKE) -C $@ $(MAKECMDGOALS)
