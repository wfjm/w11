-- $Id: crc8.vhd 410 2011-09-18 11:23:09Z mueller $
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
-- Description:    8bit CRC generator, use 'A6' polynomial of Koopman and
--                 Chakravarty. Has HD=3 for up to 247 bits and optimal HD=2
--                 error detection for longer messages:
--
--                      x^8 + x^6 + x^3 + x^2 + 1   (0xa6)
--
--                 It is irreducible, and can be implemented with <= 37 xor's
--                 This polynomial is described in
--                   http://dx.doi.org/10.1109%2FDSN.2004.1311885
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  xst 8.2, 9.1, 9.2,.., 13.1; ghdl 0.18-0.29
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2011-09-17   410 13.1    O40d xc3s1200e-4    8   25    -   13   (A6 polynom)
-- 2011-09-17   409 13.1    O40d xc3s1200e-4    8   18    -   10   (SAE J1850)
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-09-17   409   1.1    use now 'A6' polynomial of Koopman et al.
-- 2011-08-14   406   1.0.1  remove superfluous variable r
-- 2007-07-08    65   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

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
begin

  proc_regs: process (CLK)
  begin

    if rising_edge(CLK) then
      if RESET = '1' then
        R_CRC <= INIT;
      else
        if ENA = '1' then
          R_CRC <= crc8_update(R_CRC, DI);
        end if;
      end if;
    end if;

  end process proc_regs;

  CRC <= R_CRC;
  
end syn;
