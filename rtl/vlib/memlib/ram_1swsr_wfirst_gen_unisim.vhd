-- $Id: ram_1swsr_wfirst_gen_unisim.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2008- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    ram_1swsr_wfirst_gen - syn
-- Description:    Single-Port RAM with with one synchronous read/write port
--                 and 'read-through' semantics (as block RAM).
--                 Direct instantiation of Xilinx UNISIM primitives
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: Spartan-3, Virtex-2,-4
-- Tool versions:  xst 8.1-14.7; ghdl 0.18-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2008-03-08   123   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.ALL;

use work.slvtypes.all;
use work.memlib.all;

entity ram_1swsr_wfirst_gen is          -- RAM, 1 sync r/w port, write first
  generic (
    AWIDTH : positive := 11;            -- address port width
    DWIDTH : positive :=  9);           -- data port width
  port(
    CLK  : in slbit;                    -- clock
    EN   : in slbit;                    -- enable
    WE   : in slbit;                    -- write enable
    ADDR : in slv(AWIDTH-1 downto 0);   -- address
    DI   : in slv(DWIDTH-1 downto 0);   -- data in
    DO   : out slv(DWIDTH-1 downto 0)   -- data out
  );
end ram_1swsr_wfirst_gen;


architecture syn of ram_1swsr_wfirst_gen is
begin
  
  UMEM: ram_1swsr_xfirst_gen_unisim
    generic map (
      AWIDTH     => AWIDTH,
      DWIDTH     => DWIDTH,
      WRITE_MODE => "WRITE_FIRST")
    port map (
      CLK  => CLK,
      EN   => EN,
      WE   => WE,
      ADDR => ADDR,
      DI   => DI,
      DO   => DO
    );
  
end syn;
