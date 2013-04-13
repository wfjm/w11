# $Id: Makefile 489 2013-02-17 10:58:02Z mueller $
#
# 'Meta Makefile' for whole retro project
#   allows to make all synthesis targets
#   allows to make all test bench targets
#
#  Revision History: 
# Date         Rev Version  Comment
# 2012-12-29   466   1.0.5  add tst_rlink_cuff
# 2011-12-26   445   1.0.4  add tst_fx2loop
# 2011-12-23   444   1.0.3  enforce -j 1 in sub-makes
# 2011-11-27   433   1.0.2  add new nexys3 ports
# 2011-11-18   426   1.0.1  add tst_serport and tst_snhumanio
# 2011-07-09   391   1.0    Initial version
#
SYN_all += rtl/sys_gen/tst_fx2loop/nexys2/ic
SYN_all += rtl/sys_gen/tst_fx2loop/nexys2/ic3
SYN_all += rtl/sys_gen/tst_rlink/nexys2
SYN_all += rtl/sys_gen/tst_rlink/nexys3
SYN_all += rtl/sys_gen/tst_rlink/s3board
SYN_all += rtl/sys_gen/tst_rlink_cuff/nexys2/ic
SYN_all += rtl/sys_gen/tst_rlink_cuff/nexys2/ic3
SYN_all += rtl/sys_gen/tst_rlink_cuff/nexys3/ic
SYN_all += rtl/sys_gen/tst_rlink_cuff/atlys/ic
SYN_all += rtl/sys_gen/tst_serloop/nexys2
SYN_all += rtl/sys_gen/tst_serloop/nexys3
SYN_all += rtl/sys_gen/tst_serloop/s3board
SYN_all += rtl/sys_gen/tst_snhumanio/atlys
SYN_all += rtl/sys_gen/tst_snhumanio/nexys2
SYN_all += rtl/sys_gen/tst_snhumanio/nexys3
SYN_all += rtl/sys_gen/tst_snhumanio/s3board
SYN_all += rtl/sys_gen/w11a/nexys2
SYN_all += rtl/sys_gen/w11a/nexys3
SYN_all += rtl/sys_gen/w11a/s3board

SIM_all += rtl/bplib/nxcramlib/tb
SIM_all += rtl/sys_gen/tst_rlink/nexys2/tb
SIM_all += rtl/sys_gen/tst_rlink/nexys3/tb
SIM_all += rtl/sys_gen/tst_rlink/s3board/tb
SIM_all += rtl/sys_gen/tst_rlink_cuff/nexys2/ic/tb
SIM_all += rtl/sys_gen/tst_serloop/nexys2/tb
SIM_all += rtl/sys_gen/tst_serloop/nexys3/tb
SIM_all += rtl/sys_gen/tst_serloop/s3board/tb
SIM_all += rtl/sys_gen/w11a/nexys2/tb
SIM_all += rtl/sys_gen/w11a/nexys3/tb
SIM_all += rtl/sys_gen/w11a/s3board/tb
SIM_all += rtl/vlib/rlink/tb
SIM_all += rtl/vlib/serport/tb
SIM_all += rtl/w11a/tb
#
.PHONY : all clean clean_sim clean_sym all_sim all_syn
.PHONY : $(SYN_all) $(SIM_all)
#
all :
	@echo "no default action defined."
	@echo "  for VHDL simulation/synthesis use:"
	@echo "    make -j 4 all_sim"
	@echo "    make -j 4 all_syn"
	@echo "    make clean"
	@echo "    make clean_sim"
	@echo "    make clean_syn"
	@echo "  for tool/documentation generation use:"
	@echo "    make -j 4 all_lib"
	@echo "    make clean_lib"
	@echo "    make all_tcl"
	@echo "    make all_dox"
#
#
clean : clean_sim clean_syn
#
clean_sim :
	for dir in $(SIM_all); do $(MAKE) -C $$dir clean; done
clean_syn :
	for dir in $(SYN_all); do $(MAKE) -C $$dir clean; done
#
all_sim	: $(SIM_all)
#
all_syn	: $(SYN_all)
	@if [ -n "`find -name "*_par.log" | xargs grep -L 'All constraints were met'`" ] ; then \
	  echo "++++++++++ some designs have no timing closure: ++++++++++"; \
	  find -name "*_par.log" | xargs grep -L 'All constraints were met'; \
	  echo "++++++++++ ++++++++++++++++++++++++++++++++++++ ++++++++++"; \
	fi
#
# Neither ghdl nor xst allow multiple parallel compiles in one directory.
# The following ensures that the sub-makes are called with -j 1 and will
# not try to run multiple compiles on one directory.
#
$(SIM_all):
	$(MAKE) -j 1 -C $@
$(SYN_all):
	$(MAKE) -j 1 -C $@
#
all_lib :
	$(MAKE) -C tools/src
clean_lib :
	$(MAKE) -C tools/src distclean
#
all_tcl :
	(cd tools/tcl; setup_packages)
#
all_dox :
	(cd tools/dox; make_doxy)
#
all_all : all_sim all_syn all_lib all_tcl
