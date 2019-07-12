-- $Id: tbd_fifo_simple_dram.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    tbd_fifo_simple_dram - syn
-- Description:    Wrapper for fifo_simple_dram to avoid records & generics. It
--                 has a port interface which will not be modified by xst
--                 synthesis (no records, no generic port).
--
-- Dependencies:   fifo_simple_dram
--
-- To test:        fifo_simple_dram
--
-- Target Devices: generic
--
-- Tool versions:  xst 14.7; viv 2017.2; ghdl 0.35
-- Revision History: 
-- Date         Rev Version  Comment
-- 2019-02-09  1109   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.memlib.all;

entity tbd_fifo_simple_dram is          -- fifo, CE/WE, dram based [tb design]
                                        -- generic: AWIDTH=4; DWIDTH=16
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    CE : in slbit;                      -- clock enable
    WE : in slbit;                      -- write enable
    DI : in slv16;                      -- input data
    DO : out slv16;                     -- output data
    EMPTY : out slbit;                  -- fifo empty status
    FULL : out slbit;                   -- fifo full status
    SIZE : out slv4                     -- number of used slots
  );
end tbd_fifo_simple_dram;


architecture syn of tbd_fifo_simple_dram is

begin

  FIFO : fifo_simple_dram
    generic map (
      AWIDTH =>  4,
      DWIDTH => 16)
    port map (
      CLK    => CLK,
      RESET  => RESET,
      CE     => CE,
      WE     => WE,
      DI     => DI,
      DO     => DO,
      EMPTY  => EMPTY,
      FULL   => FULL,
      SIZE   => SIZE
    );
  
end syn;
