-- $Id: pdp11_dmhbpt.vhd 1203 2019-08-19 21:41:03Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2015-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Tool versions:  ise 14.7; viv 2014.4-2019.1; ghdl 0.31-0.36
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2015-07-12   700 14.7  131013 xc6slx16-2    78  133    0   42 s  3.8 (N=2)
--
-- Revision History: -
-- Date         Rev Version  Comment
-- 2019-08-17  1203   1.0.2  fix for ghdl V0.36 -Whide warnings
-- 2019-06-02  1159   1.0.1  use rbaddr_ constants
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
    RB_ADDR : slv16 := rbaddr_dmhbpt_off;
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
    HB : pdp11_dmhbpt_unit
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
