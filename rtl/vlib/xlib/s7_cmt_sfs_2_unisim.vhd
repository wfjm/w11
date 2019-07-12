-- $Id: s7_cmt_sfs_2_unisim.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2018- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    s7_cmt_sfs_2 - syn
-- Description:    Series-7 CMT for dual frequency synthesis
--                 Direct instantiation of Xilinx UNISIM primitives
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic Series-7
-- Tool versions:  viv 2017.2; ghdl 0.34
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2018-11-18  1072   1.0    Initial version (derived from s7_cmt_sfs_3_unisim)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.ALL;

use work.slvtypes.all;

entity s7_cmt_sfs_2 is                  -- 7-Series CMT for dual freq. synth.
  generic (
    VCO_DIVIDE   : positive := 1;       -- vco clock divide
    VCO_MULTIPLY : positive := 1;       -- vco clock multiply 
    OUT0_DIVIDE  : positive := 1;       -- output divide
    OUT1_DIVIDE  : positive := 1;       -- output divide
    CLKIN_PERIOD : real := 10.0;        -- CLKIN period (def is 10.0 ns)
    CLKIN_JITTER : real := 0.01;        -- CLKIN jitter (def is 10 ps)
    STARTUP_WAIT : boolean := false;    -- hold FPGA startup till LOCKED
    GEN_TYPE     : string := "PLL");    -- PLL or MMCM
  port (
    CLKIN   : in slbit;                 -- clock input
    CLKOUT0 : out slbit;                -- clock output 0
    CLKOUT1 : out slbit;                -- clock output 1
    LOCKED  : out slbit                 -- pll/mmcm locked
  );
end s7_cmt_sfs_2;


architecture syn of s7_cmt_sfs_2 is

begin
    
  assert GEN_TYPE = "PLL" or GEN_TYPE = "MMCM"
    report "assert(GEN_TYPE='PLL' or GEN_TYPE='MMCM')"
    severity failure;

  NOGEN: if VCO_DIVIDE=1 and VCO_MULTIPLY=1 and
            OUT0_DIVIDE=1 and OUT1_DIVIDE=1 generate
    CLKOUT0 <= CLKIN;
    CLKOUT1 <= CLKIN;
    LOCKED  <= '1';
  end generate NOGEN;

  USEPLL: if GEN_TYPE = "PLL" and
            not (VCO_DIVIDE=1 and VCO_MULTIPLY=1 and
                 OUT0_DIVIDE=1 and OUT1_DIVIDE=1) generate

    signal CLKFBOUT         : slbit;
    signal CLKFBOUT_BUF     : slbit;
    signal CLKOUT0_PLL      : slbit;
    signal CLKOUT1_PLL      : slbit;
    signal CLKOUT2_UNUSED   : slbit;
    signal CLKOUT3_UNUSED   : slbit;
    signal CLKOUT4_UNUSED   : slbit;
    signal CLKOUT5_UNUSED   : slbit;
    signal CLKOUT6_UNUSED   : slbit;

    pure function bool2string (val : boolean) return string is
    begin
      if val then
        return "TRUE";
      else
        return "FALSE";
      end if;
    end function bool2string;
      
  begin

    PLL : PLLE2_BASE
      generic map (
        BANDWIDTH            => "OPTIMIZED",
        DIVCLK_DIVIDE        => VCO_DIVIDE,
        CLKFBOUT_MULT        => VCO_MULTIPLY,
        CLKFBOUT_PHASE       => 0.000,
        CLKOUT0_DIVIDE       => OUT0_DIVIDE,
        CLKOUT0_PHASE        => 0.000,
        CLKOUT0_DUTY_CYCLE   => 0.500,
        CLKOUT1_DIVIDE       => OUT1_DIVIDE,
        CLKOUT1_PHASE        => 0.000,
        CLKOUT1_DUTY_CYCLE   => 0.500,
        CLKIN1_PERIOD        => CLKIN_PERIOD,
        REF_JITTER1          => CLKIN_JITTER,
        STARTUP_WAIT         => bool2string(STARTUP_WAIT))
      port map (
        CLKFBOUT            => CLKFBOUT,
        CLKOUT0             => CLKOUT0_PLL,
        CLKOUT1             => CLKOUT1_PLL,
        CLKOUT2             => CLKOUT2_UNUSED,
        CLKOUT3             => CLKOUT3_UNUSED,
        CLKOUT4             => CLKOUT4_UNUSED,
        CLKOUT5             => CLKOUT5_UNUSED,
        CLKFBIN             => CLKFBOUT_BUF,
        CLKIN1              => CLKIN,
        LOCKED              => LOCKED,
        PWRDWN              => '0',
        RST                 => '0'
      );

    BUFG_CLKFB : BUFG
      port map (
        I => CLKFBOUT,
        O => CLKFBOUT_BUF
      );

    BUFG_CLKOUT0 : BUFG
      port map (
        I => CLKOUT0_PLL,
        O => CLKOUT0
      );
    BUFG_CLKOUT1 : BUFG
      port map (
        I => CLKOUT1_PLL,
        O => CLKOUT1
      );

  end generate USEPLL;
   
  USEMMCM: if GEN_TYPE = "MMCM" and
             not (VCO_DIVIDE=1 and VCO_MULTIPLY=1 and
                  OUT0_DIVIDE=1 and OUT1_DIVIDE=1) generate

    signal CLKFBOUT         : slbit;
    signal CLKFBOUT_BUF     : slbit;
    signal CLKFBOUTB_UNUSED : slbit;
    signal CLKOUT0_MMCM     : slbit;
    signal CLKOUT0B_UNUSED  : slbit;
    signal CLKOUT1_MMCM     : slbit;
    signal CLKOUT1B_UNUSED  : slbit;
    signal CLKOUT2_UNUSED   : slbit;
    signal CLKOUT2B_UNUSED  : slbit;
    signal CLKOUT3_UNUSED   : slbit;
    signal CLKOUT3B_UNUSED  : slbit;
    signal CLKOUT4_UNUSED   : slbit;
    signal CLKOUT5_UNUSED   : slbit;
    signal CLKOUT6_UNUSED   : slbit;

  begin

    MMCM : MMCME2_BASE
      generic map (
        BANDWIDTH            => "OPTIMIZED",
        DIVCLK_DIVIDE        => VCO_DIVIDE,
        CLKFBOUT_MULT_F      => real(VCO_MULTIPLY),
        CLKFBOUT_PHASE       => 0.000,
        CLKOUT0_DIVIDE_F     => real(OUT0_DIVIDE),
        CLKOUT0_PHASE        => 0.000,
        CLKOUT0_DUTY_CYCLE   => 0.500,
        CLKOUT1_DIVIDE       => OUT1_DIVIDE,
        CLKOUT1_PHASE        => 0.000,
        CLKOUT1_DUTY_CYCLE   => 0.500,
        CLKIN1_PERIOD        => CLKIN_PERIOD,
        REF_JITTER1          => CLKIN_JITTER,
        STARTUP_WAIT         => STARTUP_WAIT)
      port map (
        CLKFBOUT            => CLKFBOUT,
        CLKFBOUTB           => CLKFBOUTB_UNUSED,
        CLKOUT0             => CLKOUT0_MMCM,
        CLKOUT0B            => CLKOUT0B_UNUSED,
        CLKOUT1             => CLKOUT1_MMCM,
        CLKOUT1B            => CLKOUT1B_UNUSED,
        CLKOUT2             => CLKOUT2_UNUSED,
        CLKOUT2B            => CLKOUT2B_UNUSED,
        CLKOUT3             => CLKOUT3_UNUSED,
        CLKOUT3B            => CLKOUT3B_UNUSED,
        CLKOUT4             => CLKOUT4_UNUSED,
        CLKOUT5             => CLKOUT5_UNUSED,
        CLKFBIN             => CLKFBOUT_BUF,
        CLKIN1              => CLKIN,
        LOCKED              => LOCKED,
        PWRDWN              => '0',
        RST                 => '0'
      );

    BUFG_CLKFB : BUFG
      port map (
        I => CLKFBOUT,
        O => CLKFBOUT_BUF
      );

    BUFG_CLKOUT0 : BUFG
      port map (
        I => CLKOUT0_MMCM,
        O => CLKOUT0
      );
    BUFG_CLKOUT1 : BUFG
      port map (
        I => CLKOUT1_MMCM,
        O => CLKOUT1
      );
    
  end generate USEMMCM;
   
end syn;
