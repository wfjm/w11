-- $Id: s6_cmt_sfs_gsim.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2013-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    s6_cmt_sfs - sim
-- Description:    Spartan-6 CMT for simple frequency synthesis
--                 simple vhdl model, without Xilinx UNISIM primitives
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic Spartan-6
-- Tool versions:  xst 14.5-14.7; ghdl 0.29-0.34
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2018-11-03  1065   1.1    use sfs_gsim_core
-- 2016-08-18   799   1.0.1  remove 'assert false' from report statements
-- 2013-10-06   538   1.0    Initial version (derived from s7_cmt_sfs_gsim)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.xlib.all;

entity s6_cmt_sfs is                    -- Spartan-6 CMT for simple freq. synth.
  generic (
    VCO_DIVIDE   : positive := 1;       -- vco clock divide
    VCO_MULTIPLY : positive := 1;       -- vco clock multiply 
    OUT_DIVIDE   : positive := 1;       -- output divide
    CLKIN_PERIOD : real := 10.0;        -- CLKIN period (def is 10.0 ns)
    CLKIN_JITTER : real := 0.01;        -- CLKIN jitter (def is 10 ps)
    STARTUP_WAIT : boolean := false;    -- hold FPGA startup till LOCKED
    GEN_TYPE     : string := "PLL");    -- PLL or MMCM
  port (
    CLKIN  : in slbit;                  -- clock input
    CLKFX  : out slbit;                 -- clock output (synthesized freq.) 
    LOCKED : out slbit                  -- pll/mmcm locked
  );
end s6_cmt_sfs;


architecture sim of s6_cmt_sfs is  
begin

  proc_init : process

    -- currently frequency limits taken from Spartan-6 speed grade -2
    constant f_vcomin_pll  : integer :=  400;
    constant f_vcomax_pll  : integer := 1000;
    constant f_pdmin_pll   : integer :=   19;
    constant f_pdmax_pll   : integer :=  375;

    variable t_vco : Delay_length := 0 ns;
    variable t_vcomin : Delay_length := 0 ns;
    variable t_vcomax : Delay_length := 0 ns;
    variable t_pd : Delay_length := 0 ns;
    variable t_pdmin : Delay_length := 0 ns;
    variable t_pdmax : Delay_length := 0 ns;

  begin
    
    -- validate generics   
    if not (GEN_TYPE = "PLL" or GEN_TYPE = "DCM") then
      report "assert(GEN_TYPE='PLL' or GEN_TYPE='DCM')"
        severity failure;
    end if;

    if VCO_DIVIDE/=1 or VCO_MULTIPLY/=1 or OUT_DIVIDE/=1 then

      if GEN_TYPE = "PLL" then
        -- check DIV/MULT parameter range
        if VCO_DIVIDE<1   or VCO_DIVIDE>52 or
           VCO_MULTIPLY<1 or VCO_MULTIPLY>64 or
           OUT_DIVIDE<1   or OUT_DIVIDE>128
        then
          report
          "assert(VCO_DIVIDE in 1:52 VCO_MULTIPLY in 1:64 OUT_DIVIDE in 1:128)"
            severity failure;
        end if;
        -- setup VCO and PD range check boundaries
        t_vcomin := (1000 ns / f_vcomax_pll) - 1 ps;
        t_vcomax := (1000 ns / f_vcomin_pll) + 1 ps;
        t_pdmin  := (1000 ns / f_pdmax_pll) - 1 ps;
        t_pdmax  := (1000 ns / f_pdmin_pll) + 1 ps;

        -- now check whether VCO and PD frequency is in range
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

    end if; -- GEN_TYPE = "PLL"

      if GEN_TYPE = "DCM" then
        -- check DIV/MULT parameter range
        if VCO_DIVIDE<1   or VCO_DIVIDE>32 or
           VCO_MULTIPLY<2 or VCO_MULTIPLY>32 or
           OUT_DIVIDE/=1
        then
          report
          "assert(VCO_DIVIDE in 1:32 VCO_MULTIPLY in 2:32 OUT_DIVIDE=1)"
            severity failure;
        end if;
      end if; -- GEN_TYPE = "MMCM"

    end if;  -- one factor /= 1
      
    wait;
  end process proc_init;

  -- generate clock
  SFS: sfs_gsim_core
    generic map (
      VCO_DIVIDE   => VCO_DIVIDE,
      VCO_MULTIPLY => VCO_MULTIPLY,
      OUT_DIVIDE   => OUT_DIVIDE)
    port map (
      CLKIN   => CLKIN,
      CLKFX   => CLKFX,
      LOCKED  => LOCKED
    );
  
end sim;
