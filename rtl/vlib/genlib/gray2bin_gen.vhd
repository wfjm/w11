-- $Id: gray2bin_gen.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2007- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
-- 
------------------------------------------------------------------------------
-- Module Name:    gray2bin_gen - syn
-- Description:    Gray code to binary converter
--
-- Dependencies:   -
-- Test bench:     tb/tb_gray_cnt_n
-- Target Devices: generic
-- Tool versions:  xst 8.1-14.7; viv 2014.4-2015.4; ghdl 0.18-0.33
-- Revision History: 
-- Date         Rev Version    Comment
-- 2007-12-26   106   1.0      Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

entity gray2bin_gen is                  -- gray->bin converter, generic vector
  generic (
    DWIDTH : positive := 4);            -- data width
  port (
    DI : in slv(DWIDTH-1 downto 0);     -- gray code input
    DO : out slv(DWIDTH-1 downto 0)     -- binary code output
  );
end entity gray2bin_gen;


architecture syn of gray2bin_gen is

begin

  proc_comb: process (DI)

    variable ido : slv(DWIDTH-1 downto 0);

  begin

    ido := (others=>'0');

    ido(DWIDTH-1) := DI(DWIDTH-1);
    for i in DWIDTH-2 downto 0 loop
      ido(i) := ido(i+1) xor DI(i);
    end loop;

    DO <= ido;

  end process proc_comb;

end syn;

