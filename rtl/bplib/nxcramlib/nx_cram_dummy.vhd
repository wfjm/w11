-- $Id: nx_cram_dummy.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2010-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
-- 
------------------------------------------------------------------------------
-- Module Name:    nx_cram_dummy - syn
-- Description:    nexys2/3: CRAM protection dummy
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  ise 11.4-14.7; viv 2014.4; ghdl 0.26-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-11-26   433   1.2    renamed from n2_cram_dummy
-- 2011-11-23   432   1.1    remove O_FLA_CE_N port
-- 2010-05-28   295   1.0.1  use _ADV_N
-- 2010-05-21   292   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

entity nx_cram_dummy is                 -- CRAM protection dummy
  port (
    O_MEM_CE_N : out slbit;             -- cram: chip enable   (act.low)
    O_MEM_BE_N : out slv2;              -- cram: byte enables  (act.low)
    O_MEM_WE_N : out slbit;             -- cram: write enable  (act.low)
    O_MEM_OE_N : out slbit;             -- cram: output enable (act.low)
    O_MEM_ADV_N  : out slbit;           -- cram: address valid (act.low)
    O_MEM_CLK : out slbit;              -- cram: clock
    O_MEM_CRE : out slbit;              -- cram: command register enable
    I_MEM_WAIT : in slbit;              -- cram: mem wait
    O_MEM_ADDR  : out slv23;            -- cram: address lines
    IO_MEM_DATA : inout slv16           -- cram: data lines
  );
end nx_cram_dummy;


architecture syn of nx_cram_dummy is
begin

  O_MEM_CE_N  <= '1';                    -- disable cram chip
  O_MEM_BE_N  <= "11";
  O_MEM_WE_N  <= '1';
  O_MEM_OE_N  <= '1';
  O_MEM_ADV_N <= '1';
  O_MEM_CLK   <= '0';
  O_MEM_CRE   <= '0';
  O_MEM_ADDR  <= (others=>'0');
  IO_MEM_DATA <= (others=>'0');
  
end syn;
