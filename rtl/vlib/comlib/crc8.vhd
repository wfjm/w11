-- $Id: crc8.vhd 406 2011-08-14 21:06:44Z mueller $
--
-- Copyright 2007-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    crc8 - syn
-- Description:    8bit CRC generator, use CRC-8-SAE J1850 polynomial.
--                 Based on  CRC-8-SAE J1850 polynomial:
--                      x^8 + x^4 + x^3 + x^2 + 1   (0x1d)
--                 It is irreducible, and can be implemented with <= 54 xor's
--
-- Notes:       #  XST synthesis for a Spartan-3 gives:
--                   1-bit xor2  :           11
--                   1-bit xor4  :            5
--                   1-bit xor5  :            1
--                   Number of 4 input LUTs: 20
--              #  Synthesis with crc8_update_tbl gives a lut-rom based table
--                 design. Even though a 256x8 bit ROM is behind, the optimizer
--                 gets it into 12 slices with 22 4 input LUTs, thus only
--                 little larger than with xor's.
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  xst 8.1, 8.2, 9.1, 9.2,.., 13.1; ghdl 0.18-0.25
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-08-14   406   1.0.1  remove superfluous variable r
-- 2007-07-08    65   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

use work.slvtypes.all;
use work.comlib.all;

entity crc8 is                          -- crc-8 generator, checker
  generic (
    INIT: slv8 :=  "00000000");         -- initial state of crc register
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    ENA : in slbit;                     -- update enable
    DI : in slv8;                       -- input data
    CRC : out slv8                      -- crc code
  );
end crc8;


architecture syn of crc8 is

  signal R_CRC : slv8 := INIT;         -- state registers
  signal N_CRC : slv8 := INIT;         -- next value state regs

begin

  proc_regs: process (CLK)
  begin

    if CLK'event and CLK='1' then
      if RESET = '1' then
        R_CRC <= INIT;
      else
        R_CRC <= N_CRC;        
      end if;
    end if;

  end process proc_regs;

  proc_next: process (R_CRC, DI, ENA)
    variable n : slv8 := INIT;
  begin

    n := R_CRC;

    if ENA = '1' then
      crc8_update(n, DI);
    end if;
    
    N_CRC <= n;

    CRC <= R_CRC;
    
  end process proc_next;


end syn;
