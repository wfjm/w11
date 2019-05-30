# $Id: Makefile 1151 2019-05-24 16:25:26Z mueller $
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
