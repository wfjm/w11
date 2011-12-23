# $Id: Makefile 442 2011-12-23 10:03:28Z mueller $
#
# 'Meta Makefile' for whole retro project
#   allows to make all synthesis targets
#   allows to make all test bench targets
#
#  Revision History: 
# Date         Rev Version  Comment
# 2011-11-27   433   1.0.2  add new nexys3 ports
# 2011-11-18   426   1.0.1  add tst_serport and tst_snhumanio
# 2011-07-09   391   1.0    Initial version
#
SYN_all += rtl/sys_gen/tst_rlink/nexys2
SYN_all += rtl/sys_gen/tst_rlink/nexys3
SYN_all += rtl/sys_gen/tst_rlink/s3board
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
	@echo "no default action defined, use"
	@echo "  make all_sim"
	@echo "  make all_syn"
	@echo "  make clean"
	@echo "  make clean_sim"
	@echo "  make clean_syn"
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
all_syn	: $(SYN_all)
#
$(SIM_all):
	$(MAKE) -C $@
$(SYN_all):
	$(MAKE) -C $@
#
