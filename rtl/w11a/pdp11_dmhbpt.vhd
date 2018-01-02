-- $Id: pdp11_dmhbpt.vhd 984 2018-01-02 20:56:27Z mueller $
--
-- Copyright 2015- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
-- This program is free software; you may redistribute and/or modify it under
-- the terms of the GNU General Public License as published by the Free
-- Software Foundation, either version 3, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
-- or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
-- for complete details.
--
------------------------------------------------------------------------------
-- Module Name:    pdp11_dmhbpt - syn
-- Description:    pdp11: debug&moni: hardware breakpoint
--
-- Dependencies:   pdp11_dmhbpt_unit
--                 rbus/rb_sres_or_4
-- Test bench:     -
--
-- Target Devices: generic
-- Tool versions:  ise 14.7; viv 2014.4; ghdl 0.31
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2015-07-12   700 14.7  131013 xc6slx16-2    78  133    0   42 s  3.8 (N=2)
--
-- Revision History: -
-- Date         Rev Version  Comment
-- 2015-07-19   702   1.0    Initial version
-- 2015-07-05   698   0.1    First draft
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.rblib.all;
use work.pdp11.all;

-- ----------------------------------------------------------------------------

entity pdp11_dmhbpt is                  -- debug&moni: hardware breakpoint
  generic (
    RB_ADDR : slv16 := slv(to_unsigned(16#0050#,16));
    NUNIT : natural := 2);
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : out rb_sres_type;         -- rbus: response
    DM_STAT_SE : in dm_stat_se_type;    -- debug and monitor status - sequencer
    DM_STAT_DP : in dm_stat_dp_type;    -- debug and monitor status - data path
    DM_STAT_VM : in dm_stat_vm_type;    -- debug and monitor status - vmbox
    DM_STAT_CO : in dm_stat_co_type;    -- debug and monitor status - core
    HBPT : out slbit                    -- hw break flag
  );
end pdp11_dmhbpt;


architecture syn of pdp11_dmhbpt is

  type sres_array_type is array (3 downto 0) of rb_sres_type;
  signal SRES_ARRAY : sres_array_type:= (others=>rb_sres_init);
  signal HBPT_SUM : slv(NUNIT-1 downto 0) := (others=>'0');
  constant hbptzero : slv(HBPT_SUM'range) := (others=>'0');

  begin

  assert NUNIT>=1 and NUNIT<=4  
    report "assert(NUNIT>=1 and NUNIT<=4): unsupported NUNIT"
    severity failure;

  GU: for i in NUNIT-1 downto 0 generate
    HBPT : pdp11_dmhbpt_unit
    generic map (
      RB_ADDR => RB_ADDR,
      INDEX   => i)
    port map (
      CLK        => CLK,
      RESET      => RESET,
      RB_MREQ    => RB_MREQ,
      RB_SRES    => SRES_ARRAY(i),
      DM_STAT_SE => DM_STAT_SE,
      DM_STAT_DP => DM_STAT_DP,
      DM_STAT_VM => DM_STAT_VM,
      DM_STAT_CO => DM_STAT_CO,
      HBPT       => HBPT_SUM(i)
    );
  end generate GU;

  GD: for i in 3 downto NUNIT generate
    SRES_ARRAY(i) <= rb_sres_init;
  end generate GD;

  RB_SRES_OR : rb_sres_or_4
    port map (
      RB_SRES_1  => SRES_ARRAY(0),
      RB_SRES_2  => SRES_ARRAY(1),
      RB_SRES_3  => SRES_ARRAY(2),
      RB_SRES_4  => SRES_ARRAY(3),
      RB_SRES_OR => RB_SRES
    );

  HBPT <= '1' when HBPT_SUM /= hbptzero else '0'; 

end syn;
