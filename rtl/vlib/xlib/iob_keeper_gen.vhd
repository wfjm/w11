-- $Id: iob_keeper_gen.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2010- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    iob_keeper_gen - sim
-- Description:    keeper for IOB, vector
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic Spartan, Virtex
-- Tool versions:  xst 8.1-14.7; ghdl 0.18-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2010-06-03   299   1.1    add explicit R_KEEP and driver
-- 2008-05-22   148   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.xlib.all;

entity iob_keeper_gen is                -- keeper for IOB, vector
  generic (
    DWIDTH : positive := 16);           -- data port width
  port (
    PAD  : inout slv(DWIDTH-1 downto 0)  -- i/o pad
  );
end iob_keeper_gen;

-- Is't possible to directly use 'PAD<='H' in proc_pad. Introduced R_KEEP and
-- the explicit driver 'PAD<=R_KEEP' to state the keeper function more clearly.

architecture sim of iob_keeper_gen is
  signal R_KEEP : slv(DWIDTH-1 downto 0) := (others=>'W');
begin

  proc_keep: process (PAD)
  begin
    for i in PAD'range loop
      if PAD(i) = '1' then
        R_KEEP(i) <= 'H';
      elsif PAD(i) = '0' then
        R_KEEP(i) <= 'L';
      elsif PAD(i)='X' or PAD(i)='U' then
        R_KEEP(i) <= 'W';
      end if;        
    end loop;
    PAD <= R_KEEP;
  end process proc_keep;

end sim;
