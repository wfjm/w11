-- $Id: sysmonrbuslib.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2016-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Package Name:   sysmonrbuslib
-- Description:    generic (all with SYSMON or XADC)
-- 
-- Dependencies:   -
-- Tool versions:  viv 2015.4-2019.1; ghdl 0.33-0.35
-- Revision History: 
-- Date         Rev Version  Comment
-- 2016-05-28   770   1.0.1  ensure to_unsigned() has a type natural argument
-- 2016-03-13   742   1.0    Initial version
-- 2016-03-06   738   0.1    First draft
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.rblib.all;

package sysmonrbuslib is

subtype bv    is bit_vector;               -- vector
subtype bv16  is bit_vector(15 downto 0);  -- 16 bit word
  
-- config reg #0 fields as bit masks (to be or'ed)
constant xadc_conf0_cavg:        bv16 := x"8000"; --    15 dis calib avr 
constant xadc_conf0_avg_off:     bv16 := x"0000"; -- 13:12 avr mode: off
constant xadc_conf0_avg_16:      bv16 := x"1000"; --   "   avr mode:  16 samples
constant xadc_conf0_avg_64:      bv16 := x"2000"; --   "   avr mode:  64 samples
constant xadc_conf0_avg_256:     bv16 := x"3000"; --   "   avr mode: 256 samples
constant xadc_conf0_mux:         bv16 := x"0800"; --    11 ena ext mux
constant xadc_conf0_bu:          bv16 := x"0400"; --    10 ena bipolar
constant xadc_conf0_ec:          bv16 := x"0200"; --     9 ena event mode
constant xadc_conf0_acq:         bv16 := x"0100"; --     8 ena inc settle
-- bit 4:0 holds channel select, not used, only for single channel mode

-- config reg #1 fields as bit masks (to be or'ed)
constant xadc_conf1_seq_default: bv16 := x"0000"; -- 15:12 seq mode: default
constant xadc_conf1_seq_spass:   bv16 := x"1000"; --   "   seq mode: single pass
constant xadc_conf1_seq_cont:    bv16 := x"2000"; --   "   seq mode: continuous
constant xadc_conf1_seq_schan:   bv16 := x"3000"; --   "   seq mode: single chan
constant xadc_conf1_dis_alm6:    bv16 := x"0800"; --    11 dis alm(6)
constant xadc_conf1_dis_alm5:    bv16 := x"0400"; --    10 dis alm(5)
constant xadc_conf1_dis_alm4:    bv16 := x"0200"; --     9 dis alm(4)
constant xadc_conf1_dis_alm3:    bv16 := x"0100"; --     8 dis alm(3)

constant xadc_conf1_cal3_supog:  bv16 := x"0080"; --     7 ena sup off+gain
constant xadc_conf1_cal2_supo:   bv16 := x"0040"; --     6 ena sup off
constant xadc_conf1_cal1_adcog:  bv16 := x"0020"; --     5 ena adc off+gain
constant xadc_conf1_cal0_adco:   bv16 := x"0010"; --     4 ena adc off

constant xadc_conf1_dis_alm2:    bv16 := x"0008"; --     3 dis alm(2)
constant xadc_conf1_dis_alm1:    bv16 := x"0004"; --     2 dis alm(1)
constant xadc_conf1_dis_alm0:    bv16 := x"0002"; --     1 dis alm(0)
constant xadc_conf1_dis_ot:      bv16 := x"0001"; --     0 dis ot

-- bit numbers for sequence registers (even word for build-in channels)
constant xadc_select_vccbram:    integer :=    14;
constant xadc_select_vrefn:      integer :=    13;
constant xadc_select_vrefp:      integer :=    12;
constant xadc_select_vpvn:       integer :=    11;
constant xadc_select_vccaux:     integer :=    10;
constant xadc_select_vccint:     integer :=     9;
constant xadc_select_temp:       integer :=     8;
constant xadc_select_vccoddr:    integer :=     7;
constant xadc_select_vccpaux:    integer :=     6;
constant xadc_select_vccpint:    integer :=     5;
constant xadc_select_calib:      integer :=     0;

-- defaults for plain build-in power monitoring
constant xadc_init_40_default: bv16 := xadc_conf0_cavg or
                                       xadc_conf0_avg_16;

constant xadc_init_41_default: bv16 := xadc_conf1_seq_cont or
                                       xadc_conf1_dis_alm6 or
                                       xadc_conf1_dis_alm5 or
                                       xadc_conf1_dis_alm4 or
                                       xadc_conf1_cal3_supog or
                                       xadc_conf1_cal2_supo or
                                       xadc_conf1_cal1_adcog or
                                       xadc_conf1_cal0_adco;

constant xadc_init_48_default: bv16 := (xadc_select_vccbram => '1',
                                        xadc_select_vccaux  => '1',
                                        xadc_select_vccint  => '1',
                                        xadc_select_temp    => '1',
                                        xadc_select_calib   => '1',
                                        others => '0');

-- OT limit and reset are in general hardwired to 125 and 70 deg
-- the 4 lsbs of reg 53 contain the 'automatic shutdown enable'
--   must be set to "0011' to enable. done by default, seems prudent
constant xadc_init_53_default: bv16 := x"ca33";  -- OT LIMIT  (125) + OT ENABLE
constant xadc_init_57_default: bv16 := x"ae40";  -- OT RESET  (70)

constant xadc_init_4a_default: bv16 := (others => '0');

pure function xadc_temp2alim(temp : real) return bv16;
pure function xadc_svolt2alim (volt : real) return bv16;

component sysmon_rbus_core is           -- SYSMON interface to rbus
  generic (
    DAWIDTH : positive :=  7;           -- drp address bus width
    ALWIDTH : positive :=  8;           -- alm width
    TEWIDTH : positive := 12;           -- temp width
    IBASE   : slv8  := x"78";            -- base of controller register window
    RB_ADDR : slv16 := x"fb00");
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit := '0';            -- reset
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : out rb_sres_type;         -- rbus: response
    SM_DEN : out slbit;                 -- sysmon: drp enable
    SM_DWE : out slbit;                 -- sysmon: drp write enable
    SM_DADDR : out slv(DAWIDTH-1 downto 0);  -- sysmon: drp address
    SM_DI : out slv16;                  -- sysmon: data input
    SM_DO : in slv16;                   -- sysmon: data output
    SM_DRDY : in slbit;                 -- sysmon: data ready
    SM_EOS : in slbit;                  -- sysmon: end of scan
    SM_RESET : out slbit;               -- sysmon: reset
    SM_ALM : in slv(ALWIDTH-1 downto 0);-- sysmon: alarms
    SM_OT : in slbit;                   -- sysmon: overtemperature
    SM_JTAGBUSY : in slbit;             -- sysmon: JTAGBUSY
    SM_JTAGLOCKED : in slbit;           -- sysmon: JTAGLOCKED
    SM_JTAGMODIFIED : in slbit;         -- sysmon: JTAGMODIFIED
    TEMP : out slv(TEWIDTH-1 downto 0)  -- die temp
  );
end component;

component sysmonx_rbus_base is          -- XADC interface to rbus (basic monitor)
  generic (
    INIT_TEMP_UP     : real :=  85.0;   -- INIT_50  (default for C grade)
    INIT_TEMP_LOW    : real :=  60.0;   -- INIT_54
    INIT_VCCINT_UP   : real :=   1.05;  -- INIT_51  (default for non-L types)
    INIT_VCCINT_LOW  : real :=   0.95;  -- INIT_55  (default for non-L types)
    INIT_VCCAUX_UP   : real :=   1.89;  -- INIT_52
    INIT_VCCAUX_LOW  : real :=   1.71;  -- INIT_56
    INIT_VCCBRAM_UP  : real :=   1.05;  -- INIT_58  (default for non-L types)
    INIT_VCCBRAM_LOW : real :=   0.95;  -- INIT_5C  (default for non-L types)
    CLK_MHZ : integer := 250;           -- clock frequency in MHz
    RB_ADDR : slv16 := x"fb00");
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit := '0';            -- reset
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : out rb_sres_type;         -- rbus: response
    ALM : out slv8;                     -- xadc: alarms
    OT :  out slbit;                    -- xadc: over temp
    TEMP : out slv12                    -- xadc: die temp
  );
end component;

component sysmonx_rbus_arty is          -- XADC interface to rbus (arty pwrmon)
  generic (
    INIT_TEMP_UP     : real :=  85.0;   -- INIT_50  (default for C grade)
    INIT_TEMP_LOW    : real :=  60.0;   -- INIT_54
    INIT_VCCINT_UP   : real :=   0.98;  -- INIT_51  (default for -1L types)
    INIT_VCCINT_LOW  : real :=   0.92;  -- INIT_55  (default for -1L types)
    INIT_VCCAUX_UP   : real :=   1.89;  -- INIT_52
    INIT_VCCAUX_LOW  : real :=   1.71;  -- INIT_56
    INIT_VCCBRAM_UP  : real :=   0.98;  -- INIT_58  (default for -1L types)
    INIT_VCCBRAM_LOW : real :=   0.92;  -- INIT_5C  (default for -1L types)
    CLK_MHZ : integer := 250;           -- clock frequency in MHz
    RB_ADDR : slv16 := x"fb00");
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit := '0';            -- reset
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : out rb_sres_type;         -- rbus: response
    ALM : out slv8;                     -- xadc: alarms
    OT :  out slbit;                    -- xadc: over temp
    TEMP : out slv12;                   -- xadc: die temp
    VPWRN : in slv4 := (others=>'0');   -- xadc: vpwr neg (4 chan pwrmon)
    VPWRP : in slv4 := (others=>'0')    -- xadc: vpwr pos (4 chan pwrmon)
  );
end component;

end package sysmonrbuslib;

-- ----------------------------------------------------------------------------
package body sysmonrbuslib is

-- -------------------------------------
pure function xadc_temp2alim(temp : real) return bv16 is
  variable ival : natural := 0;
begin
  ival := natural(((temp + 273.14) * 16.0 * 4096.0) / 503.975);
  return to_bitvector(slv(to_unsigned(ival,16)));
end function xadc_temp2alim;

-- -------------------------------------
pure function xadc_svolt2alim (volt : real) return bv16 is
  variable ival : natural := 0;
begin
  ival := natural((volt * 16.0 * 4096.0) / 3.0);
  return to_bitvector(slv(to_unsigned(ival,16)));
end function xadc_svolt2alim;


end package body sysmonrbuslib;
