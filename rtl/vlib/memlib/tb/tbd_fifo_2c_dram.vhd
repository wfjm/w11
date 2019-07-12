-- $Id: tbd_fifo_2c_dram.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2007- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    tbd_fifo_2c_dram - syn
-- Description:    Wrapper for fifo_2c_dram to avoid records & generics. It
--                 has a port interface which will not be modified by xst
--                 synthesis (no records, no generic port).
--
-- Dependencies:   fifo_2c_dram
--
-- To test:        fifo_2c_dram
--
-- Target Devices: generic
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2010-04-24   281  11.4   L68  xc3s1000-4    36   43   32   52 s 8.34 
--
-- Tool versions:  xst 8.1, 8.2, 9.1, 9.2, 11.4; ghdl 0.18-0.26
-- Revision History: 
-- Date         Rev Version  Comment
-- 2007-12-28   106   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.memlib.all;

entity tbd_fifo_2c_dram is              -- fifo, 2 clock, dram based [tb design]
                                        -- generic: AWIDTH=4; DWIDTH=16
  port (
    CLKW : in slbit;                    -- clock (write side)
    CLKR : in slbit;                    -- clock (read side)
    RESETW : in slbit;                  -- reset (synchronous with CLKW)
    RESETR : in slbit;                  -- reset (synchronous with CLKR)
    DI : in slv16;                      -- input data
    ENA : in slbit;                     -- write enable
    BUSY : out slbit;                   -- write port hold    
    DO : out slv16;                     -- output data
    VAL : out slbit;                    -- read valid
    HOLD : in slbit;                    -- read hold
    SIZEW : out slv4;                   -- number slots to write (synch w/ CLKW)
    SIZER : out slv4                    -- number slots to read  (synch w/ CLKR)
  );
end tbd_fifo_2c_dram;


architecture syn of tbd_fifo_2c_dram is

begin

  FIFO : fifo_2c_dram
    generic map (
      AWIDTH =>  4,
      DWIDTH => 16)
    port map (
      CLKW   => CLKW,
      CLKR   => CLKR,
      RESETW => RESETW,
      RESETR => RESETR,
      DI     => DI,
      ENA    => ENA,
      BUSY   => BUSY,
      DO     => DO,
      VAL    => VAL,
      HOLD   => HOLD,
      SIZEW  => SIZEW,
      SIZER  => SIZER
    );
  
end syn;
