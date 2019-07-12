-- $Id: s7_cmt_sfs_2_gsim.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2018- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    s7_cmt_sfs_2 - sim
-- Description:    Series-7 CMT  for dual-channel frequency synthesis
--                 simple vhdl model, without Xilinx UNISIM primitives
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic Series-7
-- Tool versions:  viv 2017.2; ghdl 0.34
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2018-11-18  1072   1.0    Initial version (derived from s7_cmt_sfs_3_gsim)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.xlib.all;

entity s7_cmt_sfs_2 is                  -- 7-Series CMT for dual freq. synth.
  generic (
    VCO_DIVIDE   : positive := 1;       -- vco clock divide
    VCO_MULTIPLY : positive := 1;       -- vco clock multiply 
    OUT0_DIVIDE  : positive := 1;       -- output 0 divide
    OUT1_DIVIDE  : positive := 1;       -- output 1 divide
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


architecture sim of s7_cmt_sfs_2 is
  signal LOCKED0 : slbit := '1';
  signal LOCKED1 : slbit := '1';
begin

  proc_init : process

    -- currently frequency limits taken from Artix-7 speed grade -1
    constant f_vcomin_pll  : integer :=  800;
    constant f_vcomax_pll  : integer := 1600;
    constant f_pdmin_pll   : integer :=   19;
    constant f_pdmax_pll   : integer :=  450;

    constant f_vcomin_mmcm : integer :=  600;
    constant f_vcomax_mmcm : integer := 1200;
    constant f_pdmin_mmcm  : integer :=   10;
    constant f_pdmax_mmcm  : integer :=  450;

    variable t_vco : Delay_length := 0 ns;
    variable t_vcomin : Delay_length := 0 ns;
    variable t_vcomax : Delay_length := 0 ns;
    variable t_pd : Delay_length := 0 ns;
    variable t_pdmin : Delay_length := 0 ns;
    variable t_pdmax : Delay_length := 0 ns;

  begin
    
    -- validate generics
    if not (GEN_TYPE = "PLL" or GEN_TYPE = "MMCM") then
      report "assert(GEN_TYPE='PLL' or GEN_TYPE='MMCM')"
        severity failure;
    end if;

    if VCO_DIVIDE/=1 or VCO_MULTIPLY/=1 or
       OUT0_DIVIDE/=1 or OUT1_DIVIDE/=1 then

      if GEN_TYPE = "PLL" then
        -- check DIV/MULT parameter range
        if VCO_DIVIDE<1   or VCO_DIVIDE>56 or
          VCO_MULTIPLY<2 or VCO_MULTIPLY>64 or
          OUT0_DIVIDE<1   or OUT0_DIVIDE>128 or
          OUT1_DIVIDE<1   or OUT1_DIVIDE>128
        then
          report
          "assert(VCO_DIVIDE in 1:56 VCO_MULTIPLY in 2:64 OUTx_DIVIDE in 1:128)"
            severity failure;
        end if;
        -- setup VCO and PD range check boundaries
        t_vcomin := (1000 ns / f_vcomax_pll) - 1 ps;
        t_vcomax := (1000 ns / f_vcomin_pll) + 1 ps;
        t_pdmin  := (1000 ns / f_pdmax_pll) - 1 ps;
        t_pdmax  := (1000 ns / f_pdmin_pll) + 1 ps;

      end if; -- GEN_TYPE = "PLL"

      if GEN_TYPE = "MMCM" then
        -- check DIV/MULT parameter range
        if VCO_DIVIDE<1   or VCO_DIVIDE>106 or
           VCO_MULTIPLY<2 or VCO_MULTIPLY>64 or
           OUT0_DIVIDE<1   or OUT0_DIVIDE>128 or
           OUT1_DIVIDE<1   or OUT1_DIVIDE>128
        then
          report
          "assert(VCO_DIVIDE in 1:106 VCO_MULTIPLY in 2:64 OUTx_DIVIDE in 1:128)"
            severity failure;
        end if;
        -- setup VCO and PD range check boundaries
        t_vcomin := (1000 ns / f_vcomax_mmcm) - 1 ps;
        t_vcomax := (1000 ns / f_vcomin_mmcm) + 1 ps;
        t_pdmin  := (1000 ns / f_pdmax_mmcm) - 1 ps;
        t_pdmax  := (1000 ns / f_pdmin_mmcm) + 1 ps;

      end if; -- GEN_TYPE = "MMCM"

      -- now common check whether VCO and PD frequency is in range
      t_pd  := (1 ps * (1000.0*CLKIN_PERIOD)) * VCO_DIVIDE;
      t_vco := t_pd / VCO_MULTIPLY;

      if t_vco<t_vcomin or t_vco>t_vcomax then
        report "assert(VCO frequency out of range)"
          severity failure;
      end if;
      
      if t_pd<t_pdmin or t_pd>t_pdmax then
        report "assert(PD frequency out of range)"
          severity failure;
      end if;

    end if;  -- one factor /= 1
      
    wait;
  end process proc_init;

  -- generate clock
  SFS0: sfs_gsim_core
    generic map (
      VCO_DIVIDE   => VCO_DIVIDE,
      VCO_MULTIPLY => VCO_MULTIPLY,
      OUT_DIVIDE   => OUT0_DIVIDE)
    port map (
      CLKIN   => CLKIN,
      CLKFX   => CLKOUT0,
      LOCKED  => LOCKED0
    );
  
  SFS1: sfs_gsim_core
    generic map (
      VCO_DIVIDE   => VCO_DIVIDE,
      VCO_MULTIPLY => VCO_MULTIPLY,
      OUT_DIVIDE   => OUT1_DIVIDE)
    port map (
      CLKIN   => CLKIN,
      CLKFX   => CLKOUT1,
      LOCKED  => LOCKED1
    );
  
  LOCKED <= LOCKED0 and LOCKED1;
  
end sim;
