# $Id: Makefile 893 2017-05-05 17:43:53Z mueller $
#
# 'Meta Makefile' for whole retro project
#   allows to make all synthesis targets
#   allows to make all test bench targets
#
#  Revision History: 
# Date         Rev Version  Comment
# 2017-05-01   891   1.2.7  add all_tcl to all; use njobihtm
# 2016-10-01   810   1.2.6  move component tests to SIM_viv when vivado used
# 2016-07-10   785   1.2.5  re-enable rtl/sys_gen/tst_sram/nexys4 (ok in 2016.2)
# 2016-06-05   772   1.2.4  add vmfsum,imfsum targets
# 2016-03-19   748   1.2.3  comment out legacy designs and tests
# 2016-02-19   733   1.2.2  disable rtl/sys_gen/tst_sram/nexys4 (fails in 2015.4)
# 2016-02-19   732   1.2.1  remove dispunit syn and sim entries
# 2015-02-01   640   1.2    add vivado targets, separate from ise targets
# 2015-01-25   638   1.1    drop as type fx2 targets
# 2014-06-14   562   1.0.8  suspend nexys4 syn targets
# 2013-09-28   535   1.0.7  add nexys4 port for sys_gen/tst_sram,w11a
# 2013-05-01   513   1.0.6  add clean_sim_tmp and clean_syn_tmp targets
# 2012-12-29   466   1.0.5  add tst_rlink_cuff
# 2011-12-26   445   1.0.4  add tst_fx2loop
# 2011-12-23   444   1.0.3  enforce -j 1 in sub-makes
# 2011-11-27   433   1.0.2  add new nexys3 ports
# 2011-11-18   426   1.0.1  add tst_serport and tst_snhumanio
# 2011-07-09   391   1.0    Initial version
#

# Synthesis targets --------------------------------------------------
#   ISE based targets, by board type -----------------------
#     S3board ------------------------------------

SYN_ise += rtl/sys_gen/tst_rlink/s3board
SYN_ise += rtl/sys_gen/tst_serloop/s3board
SYN_ise += rtl/sys_gen/tst_snhumanio/s3board
SYN_ise += rtl/sys_gen/tst_sram/s3board
SYN_ise += rtl/sys_gen/w11a/s3board

#     Nexys2 -------------------------------------
#SYN_ise += rtl/sys_gen/tst_fx2loop/nexys2/ic
#SYN_ise += rtl/sys_gen/tst_fx2loop/nexys2/ic3
SYN_ise += rtl/sys_gen/tst_rlink/nexys2
SYN_ise += rtl/sys_gen/tst_rlink_cuff/nexys2/ic
#SYN_ise += rtl/sys_gen/tst_rlink_cuff/nexys2/ic3
SYN_ise += rtl/sys_gen/tst_serloop/nexys2
SYN_ise += rtl/sys_gen/tst_snhumanio/nexys2
SYN_ise += rtl/sys_gen/tst_sram/nexys2
SYN_ise += rtl/sys_gen/w11a/nexys2

#     Nexys3 -------------------------------------
#SYN_ise += rtl/sys_gen/tst_fx2loop/nexys3/ic
#SYN_ise += rtl/sys_gen/tst_fx2loop/nexys3/ic3
SYN_ise += rtl/sys_gen/tst_rlink/nexys3
SYN_ise += rtl/sys_gen/tst_rlink_cuff/nexys3/ic
SYN_ise += rtl/sys_gen/tst_serloop/nexys3
SYN_ise += rtl/sys_gen/tst_snhumanio/nexys3
SYN_ise += rtl/sys_gen/tst_sram/nexys3
SYN_ise += rtl/sys_gen/w11a/nexys3

#   Vivado based targets, by board type --------------------
#     Basys3 -------------------------------------
SYN_viv += rtl/sys_gen/tst_snhumanio/basys3
#SYN_viv += rtl/sys_gen/tst_serloop/basys3
SYN_viv += rtl/sys_gen/tst_rlink/basys3
SYN_viv += rtl/sys_gen/w11a/basys3

#     Nexys4 -------------------------------------
SYN_viv += rtl/sys_gen/tst_rlink/nexys4
SYN_viv += rtl/sys_gen/tst_serloop/nexys4
SYN_viv += rtl/sys_gen/tst_snhumanio/nexys4
SYN_viv += rtl/sys_gen/tst_sram/nexys4
SYN_viv += rtl/sys_gen/w11a/nexys4

#     Arty ---------------------------------------
SYN_viv += rtl/sys_gen/tst_rlink/arty
SYN_viv += rtl/sys_gen/w11a/arty_bram

# Simulation targets -------------------------------------------------
#   ISE flow -----------------------------------------------

#     Component tests ----------------------------

#     S3board ------------------------------------
SIM_ise += rtl/sys_gen/tst_rlink/s3board/tb
SIM_ise += rtl/sys_gen/tst_serloop/s3board/tb
SIM_ise += rtl/sys_gen/tst_sram/s3board/tb
SIM_ise += rtl/sys_gen/w11a/s3board/tb

#     Nexys2 -------------------------------------
SIM_ise += rtl/sys_gen/tst_rlink/nexys2/tb
SIM_ise += rtl/sys_gen/tst_rlink_cuff/nexys2/ic/tb
SIM_ise += rtl/sys_gen/tst_serloop/nexys2/tb
SIM_ise += rtl/sys_gen/tst_sram/nexys2/tb
SIM_ise += rtl/sys_gen/w11a/nexys2/tb

#     Nexys3 -------------------------------------
SIM_ise += rtl/sys_gen/tst_rlink/nexys3/tb
SIM_ise += rtl/sys_gen/tst_rlink_cuff/nexys3/ic/tb
SIM_ise += rtl/sys_gen/tst_serloop/nexys3/tb
SIM_ise += rtl/sys_gen/tst_sram/nexys3/tb
SIM_ise += rtl/sys_gen/w11a/nexys3/tb

#   Vivado flow --------------------------------------------

#     Component tests ----------------------------
SIM_viv += rtl/bplib/issi/tb
SIM_viv += rtl/bplib/micron/tb
SIM_viv += rtl/bplib/nxcramlib/tb
SIM_viv += rtl/vlib/comlib/tb
SIM_viv += rtl/vlib/rlink/tb
SIM_viv += rtl/vlib/serport/tb
SIM_viv += rtl/w11a/tb

#     Basys3 -------------------------------------
SIM_viv += rtl/sys_gen/tst_rlink/basys3/tb
#SIM_viv += rtl/sys_gen/tst_serloop/basys3/tb
SIM_viv += rtl/sys_gen/w11a/basys3/tb

#     Nexys4 -------------------------------------
SIM_viv += rtl/sys_gen/tst_rlink/nexys4/tb
SIM_viv += rtl/sys_gen/tst_serloop/nexys4/tb
SIM_viv += rtl/sys_gen/tst_sram/nexys4/tb
SIM_viv += rtl/sys_gen/w11a/nexys4/tb

#     Arty ---------------------------------------
SIM_viv += rtl/sys_gen/tst_rlink/arty/tb
SIM_viv += rtl/sys_gen/w11a/arty_bram/tb

#
.PHONY : default
.PHONY : all all_ise all_viv
.PHONY : all_sim_ise all_syn_ise all_syn_viv
.PHONY : vmfsum imfsum
.PHONY : clean 
.PHONY : clean_sim_ise clean_sim_ise_tmp
.PHONY : clean_sym_ise clean_sim_viv clean_sym_ise_tmp clean_sym_viv_tmp 
#
# all directories most be declared as phony targets
.PHONY : $(SYN_ise) $(SIM_ise)
.PHONY : $(SYN_viv) $(SIM_viv)
#
default :
	@echo "No default action defined:"
	@echo "  for VHDL simulation/synthesis use:"
	@echo "    make -j `njobihtm -m=2G` all"
	@echo "    make -j `njobihtm -m=1G` all_ise"
	@echo "    make -j `njobihtm -m=2G` all_viv"
	@echo "    make -j `njobihtm` all_sim_ise"
	@echo "    make -j `njobihtm -m=1G` all_syn_ise"
	@echo "    make -j `njobihtm` all_sim_viv"
	@echo "    make -j `njobihtm -m=2G` all_syn_viv"
	@echo "    make vmfsum"
	@echo "    make imfsum"
	@echo "    make clean"
	@echo "    make clean_sim_ise"
	@echo "    make clean_syn_ise"
	@echo "    make clean_sim_viv"
	@echo "    make clean_syn_viv"
	@echo "    make clean_sim_ise_tmp"
	@echo "    make clean_syn_ise_tmp"
	@echo "    make clean_sim_viv_tmp"
	@echo "    make clean_syn_viv_tmp"
	@echo "  for tool/documentation generation use:"
	@echo "    make -j `njobihtm` all_lib"
	@echo "    make clean_lib"
	@echo "    make all_tcl"
	@echo "    make all_dox"
#
all     : all_ise all_viv all_lib all_tcl
all_ise : all_sim_ise all_syn_ise
all_viv : all_sim_viv all_syn_viv
#
clean : clean_sim_ise clean_syn_ise clean_sim_viv clean_syn_viv
#
clean_sim_ise :
	for dir in $(SIM_ise); do $(MAKE) -C $$dir clean; done
clean_syn_ise :
	for dir in $(SYN_ise); do $(MAKE) -C $$dir clean; done
#
clean_sim_viv :
	for dir in $(SIM_viv); do $(MAKE) -C $$dir clean; done
clean_syn_viv :
	for dir in $(SYN_viv); do $(MAKE) -C $$dir clean; done
#
clean_sim_ise_tmp :
	for dir in $(SIM_ise); do $(MAKE) -C $$dir ghdl_tmp_clean; done
clean_syn_ise_tmp :
	for dir in $(SYN_ise); do $(MAKE) -C $$dir ise_tmp_clean; done
#
clean_sim_viv_tmp :
	for dir in $(SIM_viv); do $(MAKE) -C $$dir ghdl_tmp_clean; done
clean_syn_viv_tmp :
	for dir in $(SYN_viv); do $(MAKE) -C $$dir viv_tmp_clean; done
#
all_sim_ise : $(SIM_ise)
#
all_syn_ise : $(SYN_ise)
	@if [ -n "`find -name "*_par.log" | xargs grep -L 'All constraints were met'`" ] ; then \
	  echo "++++++++++ some designs have no timing closure: ++++++++++"; \
	  find -name "*_par.log" | xargs grep -L 'All constraints were met'; \
	  echo "++++++++++ ++++++++++++++++++++++++++++++++++++ ++++++++++"; \
	else \
	  echo "++++++++++ all ISE designs have timing closure ++++++++++"; \
	fi
#
all_sim_viv : $(SIM_viv)
#
all_syn_viv : $(SYN_viv)
	@if [ -n "`find -name "*_rou_tim.rpt" | xargs grep -L 'All user specified timing constraints are met'`" ] ; then \
	  echo "++++++++++ some designs have no timing closure: ++++++++++"; \
	  find -name "*_rou_tim.rpt" | xargs grep -L 'All user specified timing constraints are met'; \
	  echo "++++++++++ ++++++++++++++++++++++++++++++++++++ ++++++++++"; \
	else \
	  echo "++++++++++ all Vivado designs have timing closure ++++++++++"; \
	fi
#
# Neither ghdl nor Xilinx tools allow multiple parallel compiles in one 
# directory. The following ensures that the sub-makes are called with -j 1 
# and will not try to run multiple compiles on one directory.
#
$(SIM_ise):
	$(MAKE) -j 1 -C $@
$(SYN_ise):
	$(MAKE) -j 1 -C $@
#
$(SIM_viv):
	$(MAKE) -j 1 -C $@
$(SYN_viv):
	$(MAKE) -j 1 -C $@
#
vmfsum :
	@xviv_msg_summary
imfsum :
	@xise_msg_summary
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

