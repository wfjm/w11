-- $Id: gray_cnt_gen.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2007- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
-- 
------------------------------------------------------------------------------
-- Module Name:    gray_cnt_gen - syn
-- Description:    Generic width Gray code counter
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  xst 8.1-14.7; viv 2014.4-2015.4; ghdl 0.18-0.33
-- Revision History: 
-- Date         Rev Version    Comment
-- 2007-12-26   106   1.0      Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.genlib.all;

entity gray_cnt_gen is                  -- gray code counter, generic vector
  generic (
    DWIDTH : positive := 4);            -- data width
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit := '0';            -- reset
    CE : in slbit := '1';               -- count enable
    DATA : out slv(DWIDTH-1 downto 0)   -- data out
  );
end entity gray_cnt_gen;


architecture syn of gray_cnt_gen is

begin
  
  assert DWIDTH>=4
    report "assert(DWIDTH>=4): only 4 or more bit width supported"
    severity failure;


  GRAY_4: if DWIDTH=4 generate
  begin
    CNT : gray_cnt_4
      port map (
        CLK   => CLK,
        RESET => RESET,
        CE    => CE,
        DATA  => DATA
      );
  end generate GRAY_4;

  GRAY_5: if DWIDTH=5 generate
  begin
    CNT : gray_cnt_5
      port map (
        CLK   => CLK,
        RESET => RESET,
        CE    => CE,
        DATA  => DATA
      );
  end generate GRAY_5;

  GRAY_N: if DWIDTH>5 generate
  begin
    CNT : gray_cnt_n
      generic map (
        DWIDTH => DWIDTH)
      port map (
        CLK   => CLK,
        RESET => RESET,
        CE    => CE,
        DATA  => DATA
      );
  end generate GRAY_N;

end syn;

