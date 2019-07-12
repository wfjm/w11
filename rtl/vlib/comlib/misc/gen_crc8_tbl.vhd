-- $Id: gen_crc8_tbl.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2007-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    gen_crc8_tbl - sim
-- Description:    stand-alone program to print crc8 transition table
--
-- Dependencies:   comlib/crc8_update (function)
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-09-17   410   1.1    now numeric_std clean; use function crc8_update
-- 2007-10-12    88   1.0.1  avoid ieee.std_logic_unsigned, use cast to unsigned
-- 2007-07-08    65   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

use work.slvtypes.all;
use work.comlib.all;

entity gen_crc8_tbl is
end gen_crc8_tbl;

architecture sim of gen_crc8_tbl is
begin
  
  process
    variable crc : slv8 := (others=>'0');
    variable dat : slv8 := (others=>'0');
    variable nxt : slv8 := (others=>'0');
    variable oline : line;
  begin
    for i in 0 to 255 loop
      crc := (others=>'0');
      dat := slv(to_unsigned(i,8));
      nxt := crc8_update(crc, dat);
      write(oline, to_integer(unsigned(nxt)), right, 4);
      if i /= 255 then
        write(oline, string'(","));
      end if;
      if (i mod 8) = 7 then
        writeline(output, oline);
      end if;
    end loop;  -- i
    wait;
  end process;

end sim;
