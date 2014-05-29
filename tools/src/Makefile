# $Id: Makefile 530 2013-08-09 21:25:04Z mueller $
#
# Top level makefile, using the recipe found in
#    http://www.lackof.org/taggart/hacking/make-example/
#
#  Revision History: 
# Date         Rev Version  Comment
# 2013-02-01   479   1.2.2  correct so names for *w11* libs
# 2013-01-27   478   1.2.1  add librlw11(tpp)
# 2011-03-20   372   1.1.1  renamed ..tcl -> ..tpp
# 2011-03-14   370   1.1.0  rename librtoolstcl -> librtcltools
# 2011-02-13   361   1.1    add realclean rule; add dirs and dependencies
# 2011-01-30   357   1.0    Initial version
#
DIRS  = librtools
DIRS += librlink
DIRS += librw11
DIRS += librtcltools 
DIRS += librutiltpp
DIRS += librlinktpp
DIRS += librwxxtpp
#
BUILDDIRS = $(DIRS:%=build-%)
CLEANDIRS = $(DIRS:%=clean-%)
DISTCDIRS = $(DIRS:%=distc-%)
#
.PHONY: all clean distclean
.PHONY: $(DIRS)
.PHONY: $(BUILDDIRS)
.PHONY: $(CLEANDIRS)
.PHONY: $(DISTCDIRS)
#
# build 'all' rule
#
all: $(BUILDDIRS)
#
build-librw11       : build-librlink
build-librlink      : build-librtools
build-librtcltools  : build-librtools
build-librutiltpp   : build-librtcltools
build-librwxxtpp    : build-librw11  build-librtcltools
build-librlinktpp   : build-librlink build-librtcltools
#
$(BUILDDIRS):
	$(MAKE) -C $(@:build-%=%)
#
# clean rule
#
clean: $(CLEANDIRS)
$(CLEANDIRS): 
	$(MAKE) -C $(@:clean-%=%) clean
#
# distclean rule
#
distclean: $(DISTCDIRS)
$(DISTCDIRS): 
	$(MAKE) -C $(@:distc-%=%) distclean
