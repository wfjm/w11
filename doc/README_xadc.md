The Artix-7 based designs contain now a module which makes the data of the
FPGA system monitor, called XADC in 7Series and SYSMON otherwise, available
on the rbus and therefore from `ti_rri`.

To set this up in `ti_rri` or `ti_w11` use

    package require rbsysmon
    rbsysmon::setup_xadc_arty;      # for arty
    rbsysmon::setup_xadc_base;      # for b3,n4

Two procedures allow to read and nicely print the XADC data

    rbsysmon::print
      --> gives on an Arty for example
      Value     cur val     min val   max val   low lim  high lim  alarm
      temp       34.3   d    30.8      36.0      60.0      85.0         
      Vccint      0.948 V     0.944     0.953     0.920     0.980       
      Vccaux      1.799 V     1.787     1.802     1.710     1.890       
      Vccbram     0.948 V     0.944     0.954     0.920     0.980       
      V 5V0       4.978 V
      V VU        0.088 V
      A 5V0       0.173 A
      A 0V95      0.087 A

    rbsysmon::print_raw
      --> produces a full list of all defined registers, like
      name        description         :  hex  other
      sm.temp     cur temp            : 9a50    30.6   deg
      sm.vint     cur Vccint          : 50ce     0.947 V
      sm.vaux     cur Vccaux          : 9962     1.797 V
      sm.vrefp    cur Vrefp           : 0000     0.000 V
      ....
      sm.flag     flag reg            : 0000  0000000000000000
      sm.conf0    conf 0              : 9000  1001000000000000
      sm.conf1    conf 1              : 2ef0  0010111011110000
      sm.conf2    conf 2              : 0400  0000010000000000
      ....

For simulation proper setup files are included and activated by tbw to that
one sees in simulation nominal readings for the power monitor values. To
test this do for example

    cd $RETROBASE/rtl/sys_gen/tst_rlink/arty/tb
    make
    ti_rri --fifo=,xon --run='tbw tb_tst_rlink_arty'

    .. commands above ...
