# $Id: Makefile 429 2011-11-20 12:54:56Z mueller $
#
# Top level makefile, using the recipe found in
#    http://www.lackof.org/taggart/hacking/make-example/
#
#  Revision History: 
# Date         Rev Version  Comment
# 2011-07-31   401   1.2    rename realclean->distclean; add librusbtpp
# 2011-03-20   372   1.1.1  renamed ..tcl -> ..tpp
# 2011-03-14   370   1.1.0  rename librtoolstcl -> librtcltools
# 2011-02-13   361   1.1    add realclean rule; add dirs and dependencies
# 2011-01-30   357   1.0    Initial version
#
DIRS  = librtools
DIRS += librlink
DIRS += librtcltools 
DIRS += librutiltpp
DIRS += librlinktpp
#
BUILDDIRS = $(DIRS:%=build-%)
CLEANDIRS = $(DIRS:%=clean-%)
REALCDIRS = $(DIRS:%=distc-%)
#
.PHONY: all clean distclean
.PHONY: $(DIRS)
.PHONY: $(BUILDDIRS)
.PHONY: $(CLEANDIRS)
.PHONY: $(REALCDIRS)
#
# build 'all' rule
#
all: $(BUILDDIRS)
#
build-librlink      : build-librtools
build-librtcltools  : build-librtools
build-librutiltpp   : build-librtcltools
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
distclean: $(REALCDIRS)
$(REALCDIRS): 
	$(MAKE) -C $(@:distc-%=%) distclean
