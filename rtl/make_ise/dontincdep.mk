# $Id: dontincdep.mk 1176 2019-06-30 07:16:06Z mueller $
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
#  Revision History: 
# Date         Rev Version  Comment
# 2013-01-27   477   1.0    Initial version
#
# DONTINCDEP controls whether dependency files are included. Set it if
# any of the 'clean' type targets is involved
#
ifneq  ($(findstring clean, $(MAKECMDGOALS)),)
DONTINCDEP = 1
endif
ifneq  ($(findstring realclean, $(MAKECMDGOALS)),)
DONTINCDEP = 1
endif
ifneq  ($(findstring distclean, $(MAKECMDGOALS)),)
DONTINCDEP = 1
endif
ifdef DONTINCDEP
$(info DONTINCDEP set, *.dep files not included)
endif
