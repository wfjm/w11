-- $Id: n2_cram_dummy.vhd 314 2010-07-09 17:38:41Z mueller $
--
-- Copyright 2010- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    n2_cram_dummy - syn
-- Description:    nexys2: CRAM protection dummy
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  xst 11.4; ghdl 0.26
-- Revision History: 
-- Date         Rev Version  Comment
-- 2010-05-28   295   1.0.1  use _ADV_N
-- 2010-05-21   292   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

use work.slvtypes.all;

entity n2_cram_dummy is                 -- CRAM protection dummy
  port (
    O_MEM_CE_N : out slbit;             -- cram: chip enable   (act.low)
    O_MEM_BE_N : out slv2;              -- cram: byte enables  (act.low)
    O_MEM_WE_N : out slbit;             -- cram: write enable  (act.low)
    O_MEM_OE_N : out slbit;             -- cram: output enable (act.low)
    O_MEM_ADV_N  : out slbit;           -- cram: address valid (act.low)
    O_MEM_CLK : out slbit;              -- cram: clock
    O_MEM_CRE : out slbit;              -- cram: command register enable
    I_MEM_WAIT : in slbit;              -- cram: mem wait
    O_FLA_CE_N : out slbit;             -- flash ce..          (act.low)
    O_MEM_ADDR  : out slv23;            -- cram: address lines
    IO_MEM_DATA : inout slv16           -- cram: data lines
  );
end n2_cram_dummy;


architecture syn of n2_cram_dummy is
begin

  O_MEM_CE_N  <= '1';                    -- disable cram chip
  O_MEM_BE_N  <= "11";
  O_MEM_WE_N  <= '1';
  O_MEM_OE_N  <= '1';
  O_MEM_ADV_N <= '1';
  O_MEM_CLK   <= '0';
  O_MEM_CRE   <= '0';
  O_FLA_CE_N  <= '1';
  O_MEM_ADDR  <= (others=>'0');
  IO_MEM_DATA <= (others=>'0');
  
end syn;
