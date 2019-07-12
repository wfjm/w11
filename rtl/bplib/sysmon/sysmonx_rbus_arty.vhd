-- $Id: sysmonx_rbus_arty.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2016-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    sysmonx_rbus_arty - syn
-- Description:    7series XADC interface to rbus (arty pwrmon version)
--
-- Dependencies:   sysmon_rbus_core
--
-- Test bench:     -
--
-- Target Devices: 7series
-- Tool versions:  viv 2015.4-2019.1; ghdl 0.33-0.35
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2016-03-12   741   1.0    Initial version
-- 2016-03-06   738   0.1    First draft
------------------------------------------------------------------------------
--
-- rbus registers: see sysmon_rbus_core and XADC user guide
--
-- XADC usage:
--   - build-in sensors: temp, Vccint, Vccaux, Vccbram
--   - arty power monitoring:
--       VAUX( 1)  VPWR(0) <- 1/5.99 of JPR5V0 (main 5 V line)
--       VAUX( 2)  VPWR(1) <- 1/16 of VU (external power jack)
--       VAUX( 9)  VPWR(2) <- 250mV/A from shunt on JPR5V0 (main 5 V line)
--       VAUX(10)  VPWR(3) <- 500mV/A from shunt on VCC0V95 (FPGA core)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.ALL;

use work.slvtypes.all;
use work.rblib.all;
use work.sysmonrbuslib.all;

-- ----------------------------------------------------------------------------

entity sysmonx_rbus_arty is             -- XADC interface to rbus (for arty)
  generic (
    INIT_OT_LIMIT    : real := 125.0;   -- INIT_53
    INIT_OT_RESET    : real :=  70.0;   -- INIT_57
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
end sysmonx_rbus_arty;

architecture syn of sysmonx_rbus_arty is

  constant vpwrmap_0 : integer :=  1;   -- map vpwr(0) -> xadc vaux
  constant vpwrmap_1 : integer :=  2;   -- map vpwr(1) -> xadc vaux
  constant vpwrmap_2 : integer :=  9;   -- map vpwr(2) -> xadc vaux
  constant vpwrmap_3 : integer := 10;   -- map vpwr(3) -> xadc vaux

  constant conf2_cd : integer := (CLK_MHZ+25)/26; -- clock division ratio
  constant init_42 : bv16 := to_bitvector(slv(to_unsigned(256*conf2_cd,16)));

  constant init_49 : bv16 := (vpwrmap_0 => '1',   -- seq  #1: (enable pwrmon)
                              vpwrmap_1 => '1',
                              vpwrmap_2 => '1',
                              vpwrmap_3 => '1',
                              others => '0');
  
  signal VAUXN : slv16 := (others=>'0');
  signal VAUXP : slv16 := (others=>'0');
  
  signal SM_DEN   : slbit := '0';
  signal SM_DWE   : slbit := '0';
  signal SM_DADDR : slv7  := (others=>'0');
  signal SM_DI    : slv16 := (others=>'0');
  signal SM_DO    : slv16 := (others=>'0');
  signal SM_DRDY  : slbit := '0';
  signal SM_EOS   : slbit := '0';
  signal SM_EOC   : slbit := '0';
  signal SM_RESET : slbit := '0';
  signal SM_CHAN  : slv5  := (others=>'0');
  signal SM_ALM   : slv8  := (others=>'0');
  signal SM_OT    : slbit := '0';
  signal SM_JTAGLOCKED   : slbit := '0';
  signal SM_JTAGMODIFIED : slbit := '0';
  signal SM_JTAGBUSY     : slbit := '0';

begin

  SM : XADC
    generic map (
      INIT_40  => xadc_init_40_default, -- conf #0
      INIT_41  => xadc_init_41_default, -- conf #1
      INIT_42  => init_42,
      INIT_43  => x"0000",              -- test #0 - don't use, stay 0
      INIT_44  => x"0000",              -- test #1 - "
      INIT_45  => x"0000",              -- test #2 - "
      INIT_46  => x"0000",              -- test #3 - "
      INIT_47  => x"0000",              -- test #4 - "
      INIT_48  => xadc_init_48_default, -- seq  #0: sel  0
      INIT_49  => init_49,              -- seq  #1: sel  1 (enable pwrmon)
      INIT_4A  => xadc_init_4a_default, -- seq  #2: avr  0
      INIT_4B  => x"0000",              -- seq  #3: avr  1: "
      INIT_4C  => x"0000",              -- seq  #4: mode 0: unipolar
      INIT_4D  => x"0000",              -- seq  #5: mode 1: "
      INIT_4E  => x"0000",              -- seq  #6: time 0: fast
      INIT_4F  => x"0000",              -- seq  #7: time 1: "
      INIT_50  => xadc_temp2alim(INIT_TEMP_UP),     -- alm #00:   temp  up (0)
      INIT_51  => xadc_svolt2alim(INIT_VCCINT_UP),  -- alm #01:  ccint  up (1)
      INIT_52  => xadc_svolt2alim(INIT_VCCAUX_UP),  -- alm #02:  ccaux  up (2)
      INIT_53  => xadc_init_53_default,             -- alm #03:  OT limit   OT
      INIT_54  => xadc_temp2alim(INIT_TEMP_LOW),    -- alm #04:   temp low (0)
      INIT_55  => xadc_svolt2alim(INIT_VCCINT_LOW), -- alm #05:  ccint low (1)
      INIT_56  => xadc_svolt2alim(INIT_VCCAUX_LOW), -- alm #06:  ccaux low (2)
      INIT_57  => xadc_init_57_default,             -- alm #07:  OT reset   OT
      INIT_58  => xadc_svolt2alim(INIT_VCCBRAM_UP), -- alm #08: ccbram  up (3)
      INIT_59  => x"0000",                          -- alm #09: ccpint  up (4)
      INIT_5A  => x"0000",                          -- alm #10: ccpaux  up (5)
      INIT_5B  => x"0000",                          -- alm #11: ccdram  up (6)
      INIT_5C  => xadc_svolt2alim(INIT_VCCBRAM_LOW),-- alm #12: ccbram low (3)
      INIT_5D  => x"0000",                          -- alm #13: ccpint low (4)
      INIT_5E  => x"0000",                          -- alm #14: ccpaux low (5)
      INIT_5F  => x"0000",                          -- alm #15: ccdram low (6)
--      IS_CONVSTCLK_INVERTED => '0',
--      IS_DCLK_INVERTED      => '0',
      SIM_DEVICE            => "7SERIES",
      SIM_MONITOR_FILE      => "sysmon_stim")
    port map (
      DCLK    => CLK,
      DEN     => SM_DEN,
      DWE     => SM_DWE,
      DADDR   => SM_DADDR,
      DI      => SM_DI,
      DO      => SM_DO,
      DRDY    => SM_DRDY,
      EOC     => SM_EOC,                -- connected for tb usage
      EOS     => SM_EOS,
      BUSY    => open,
      RESET   => SM_RESET,
      CHANNEL => SM_CHAN,               -- connected for tb usage
      MUXADDR => open,
      ALM     => SM_ALM,
      OT      => SM_OT,
      CONVST       => '0',
      CONVSTCLK    => '0',
      JTAGBUSY     => SM_JTAGBUSY,
      JTAGLOCKED   => SM_JTAGLOCKED,
      JTAGMODIFIED => SM_JTAGMODIFIED,
      VAUXN   => VAUXN,
      VAUXP   => VAUXP,
      VN      => '0',
      VP      => '0'
    );

  VAUXN <= (vpwrmap_0 => VPWRN(0),
            vpwrmap_1 => VPWRN(1),
            vpwrmap_2 => VPWRN(2),
            vpwrmap_3 => VPWRN(3),
            others=>'0');
  VAUXP <= (vpwrmap_0 => VPWRP(0),
            vpwrmap_1 => VPWRP(1),
            vpwrmap_2 => VPWRP(2),
            vpwrmap_3 => VPWRP(3),
            others=>'0');
 
  SMRB : sysmon_rbus_core
    generic map (
      DAWIDTH =>  7,
      ALWIDTH =>  8,
      TEWIDTH => 12,
      IBASE   => x"78",
      RB_ADDR => RB_ADDR)
    port map (
      CLK      => CLK,
      RESET    => RESET,
      RB_MREQ  => RB_MREQ,
      RB_SRES  => RB_SRES,
      SM_DEN   => SM_DEN,
      SM_DWE   => SM_DWE,
      SM_DADDR => SM_DADDR,
      SM_DI    => SM_DI,
      SM_DO    => SM_DO,
      SM_DRDY  => SM_DRDY,
      SM_EOS   => SM_EOS,
      SM_RESET => SM_RESET,
      SM_ALM   => SM_ALM,
      SM_OT    => SM_OT,
      SM_JTAGBUSY     => SM_JTAGBUSY,
      SM_JTAGLOCKED   => SM_JTAGLOCKED,
      SM_JTAGMODIFIED => SM_JTAGMODIFIED,
      TEMP     => TEMP
    );  

  ALM   <= SM_ALM;
  OT    <= SM_OT;

end syn;
