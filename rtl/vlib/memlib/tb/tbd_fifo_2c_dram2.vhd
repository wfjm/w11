-- $Id: tbd_fifo_2c_dram2.vhd 984 2018-01-02 20:56:27Z mueller $
--
-- Copyright 2016- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
-- This program is free software; you may redistribute and/or modify it under
-- the terms of the GNU General Public License as published by the Free
-- Software Foundation, either version 3, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
-- or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
-- for complete details.
--
------------------------------------------------------------------------------
-- Module Name:    tbd_fifo_2c_dram2 - syn
-- Description:    Wrapper for fifo_2c_dram2 to avoid records & generics. It
--                 has a port interface which will not be modified by synthesis
--                 (no records, no generic port).
--
-- Dependencies:   fifo_2c_dram2
--
-- To test:        fifo_2c_dram2
--
-- Target Devices: generic
--
-- Tool versions:  viv 2015.4; ghdl 0.33
-- Revision History: 
-- Date         Rev Version  Comment
-- 2007-12-28   106   1.0    Initial version (tbd_fifo_2c_dram2)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.memlib.all;

entity tbd_fifo_2c_dram2 is             -- fifo, 2 clock, dram based [tb design]
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
end tbd_fifo_2c_dram2;


architecture syn of tbd_fifo_2c_dram2 is

begin

  FIFO : fifo_2c_dram2
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
