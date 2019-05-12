# $Id: Makefile 1147 2019-05-11 07:08:40Z mueller $
#
#  Revision History: 
# 2019-05-07  1147   1.0    Initial version
#
DIRS  = dl11
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
