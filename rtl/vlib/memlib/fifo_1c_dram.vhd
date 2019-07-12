-- $Id: fifo_1c_dram.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2007- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    fifo_1c_dram - syn
-- Description:    FIFO, single clock domain, distributed RAM based, with
--                 enable/busy/valid/hold interface.
--
-- Dependencies:   fifo_1c_dram_raw
--
-- Test bench:     tb/tb_fifo_1c_dram
-- Target Devices: generic Spartan, Virtex
-- Tool versions:  ise 8.1-14.7; viv 2014.4; ghdl 0.18-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2007-06-06    49   1.0    Initial version 
--
-- Some synthesis results:
-- - 2007-12-27 ise 8.2.03 for xc3s1000-ft256-4:
--   AWIDTH DWIDTH  LUT.l LUT.m  Flop   clock(xst est.)
--        4     16     31    32    22   153MHz     ( 16 words)
--        5     16     49    64    23   120MHz     ( 32 words)
--        6     16     70   128    23   120MHz     ( 64 words)
--        7     16    111   256    30   120MHz     (128 words)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.memlib.all;

entity fifo_1c_dram is                  -- fifo, 1 clock, dram based
  generic (
    AWIDTH : positive :=  7;            -- address width (sets size)
    DWIDTH : positive := 16);           -- data width
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    DI : in slv(DWIDTH-1 downto 0);     -- input data
    ENA : in slbit;                     -- write enable
    BUSY : out slbit;                   -- write port hold    
    DO : out slv(DWIDTH-1 downto 0);    -- output data
    VAL : out slbit;                    -- read valid
    HOLD : in slbit;                    -- read hold
    SIZE : out slv(AWIDTH downto 0)     -- number of used slots
  );
end fifo_1c_dram;


architecture syn of fifo_1c_dram is

  signal WE : slbit := '0';
  signal RE : slbit := '0';
  signal SIZE_L : slv(AWIDTH-1 downto 0) := (others=>'0');
  signal EMPTY : slbit := '0';
  signal FULL : slbit := '0';
  
begin

  FIFO : fifo_1c_dram_raw
    generic map (
      AWIDTH => AWIDTH,
      DWIDTH => DWIDTH)
    port map (
      CLK   => CLK,
      RESET => RESET,
      WE => WE,
      RE => RE,
      DI => DI,
      DO => DO,
      SIZE => SIZE_L,
      EMPTY => EMPTY,
      FULL => FULL
    );

  WE <= ENA and (not FULL);
  RE <= (not EMPTY) and (not HOLD);

  BUSY <= FULL;
  VAL  <= not EMPTY;
  SIZE <= FULL & SIZE_L;

end syn;
