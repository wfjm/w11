-- $Id: gen_crc8_tbl.vhd 314 2010-07-09 17:38:41Z mueller $
--
-- Copyright 2007- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
-- This program is free software; you may redistribute and/or modify it under
-- the terms of the GNU General Public License as published by the Free
-- Software Foundation, either version 2, or at your option any later version.
--
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
-- or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
-- for complete details.
--
------------------------------------------------------------------------------
-- Module Name:    gen_crc8_tbl - sim
-- Description:    stand-alone program to print crc8 transition table
--
-- Dependencies:   comlib/crc8_update (procedure)
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2007-10-12    88   1.0.1  avoid ieee.std_logic_unsigned, use cast to unsigned
-- 2007-07-08    65   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_textio.all;
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
    variable oline : line;
  begin
    for i in 0 to 255 loop
      crc := (others=>'0');
      dat := conv_std_logic_vector(i,8);
      crc8_update(crc, dat);
      write(oline, conv_integer(unsigned(crc)), right, 4);
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
