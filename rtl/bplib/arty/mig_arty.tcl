# $Id: mig_arty.tcl 1092 2018-12-24 08:01:50Z mueller $
#
# Copyright 2018- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see License.txt in $RETROBASE directory
#
# Revision History:
# Date         Rev Version  Comment
# 2018-12-19  1090   1.0    Initial version
# 2018-11-18  1072   0.1    First draft
#

# defined tested MIG versions with project files
set tdsc_list { "4.0" "mig_a.prj" \
                "4.1" "mig_a.prj" \
                "4.2" "mig_a.prj" }

# determine available MIG version (only latest supported !!)
set vlnv [get_ipdefs "xilinx.com:ip:mig_7series:*"]
set vers [lindex [split $vlnv ":"] 3]

# filter out matching MIG version

set mprj {}
foreach {tver tprj} $tdsc_list {
  lappend tver_list $tver
  if {$vers eq $tver} { set mprj $tprj }
}

puts [format "## tested    MIG versions: %s" [join $tver_list "  "]]
puts [format "## available MIG version:  %s" $vers]

if {$mprj ne ""} {
  puts [format "## selected  MIG version:  %s with %s" $vers $mprj]
} else {
  error "sramif_mig_arty: no tested MIG version found"
}

create_ip -vlnv "xilinx.com:ip:mig_7series:$vers" -module_name migui_arty

set ip_dir [get_property IP_DIR [ get_ips ips migui_arty]]
##puts "ip_dir: $ip_dir"
puts "## migui: copy $mprj to IP_DIR"
file copy $mprj "$ip_dir/$mprj"

puts "## migui: set_property"
set_property -dict [list \
                      CONFIG.XML_INPUT_FILE $mprj \
                      CONFIG.RESET_BOARD_INTERFACE {Custom} \
                      CONFIG.MIG_DONT_TOUCH_PARAM {Custom} \
                      CONFIG.BOARD_MIG_PARAM {Custom} \
                     ] \
                    [get_ips migui_arty]

puts "## migui: generate_target"
generate_target {instantiation_template} \
  [get_files "$ip_dir/migui_arty.xci"]

puts "## migui: export_ip_user_files"
export_ip_user_files -of_objects \
  [get_files "$ip_dir/migui_arty.xci"] \
  -no_script -sync -force -quiet
