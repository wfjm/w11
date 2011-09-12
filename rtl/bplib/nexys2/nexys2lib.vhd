-- $Id: nexys2lib.vhd 389 2011-07-07 21:59:00Z mueller $
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
-- Package Name:   nexys2lib
-- Description:    Nexys 2 components
-- 
-- Dependencies:   -
-- Tool versions:  xst 11.4, 12.1; ghdl 0.26-0.29
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2010-11-13   338   1.0.2  add O_CLKSYS to aif's (DCM derived system clock)
-- 2010-11-06   336   1.0.4  rename input pin CLK -> I_CLK50
-- 2010-05-28   295   1.0.3  use _ADV_N also for n2_cram_dummy
-- 2010-05-23   294   1.0.2  add n2_cram_dummy;
-- 2010-05-23   293   1.0.1  use _ADV_N rather _ADV; add generic for memctl
-- 2010-05-21   292   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

package nexys2lib is

component nexys2_aif is                 -- NEXYS 2, abstract iface, base
  port (
    I_CLK50 : in slbit;                 -- 50 MHz board clock
    O_CLKSYS : out slbit;               -- DCM derived system clock
    I_RXD : in slbit;                   -- receive data (board view)
    O_TXD : out slbit;                  -- transmit data (board view)
    I_SWI : in slv8;                    -- s3 switches
    I_BTN : in slv4;                    -- s3 buttons
    O_LED : out slv8;                   -- s3 leds
    O_ANO_N : out slv4;                 -- 7 segment disp: anodes   (act.low)
    O_SEG_N : out slv8;                 -- 7 segment disp: segments (act.low)
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
end component;

component nexys2_fusp_aif is           -- NEXYS 2, abstract iface, base+fusp
  port (
    I_CLK50 : in slbit;                 -- 50 MHz board clock
    O_CLKSYS : out slbit;               -- DCM derived system clock
    I_RXD : in slbit;                   -- receive data (board view)
    O_TXD : out slbit;                  -- transmit data (board view)
    I_SWI : in slv8;                    -- s3 switches
    I_BTN : in slv4;                    -- s3 buttons
    O_LED : out slv8;                   -- s3 leds
    O_ANO_N : out slv4;                 -- 7 segment disp: anodes   (act.low)
    O_SEG_N : out slv8;                 -- 7 segment disp: segments (act.low)
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
    IO_MEM_DATA : inout slv16;          -- cram: data lines
    O_FUSP_RTS_N : out slbit;           -- fusp: rs232 rts_n
    I_FUSP_CTS_N : in slbit;            -- fusp: rs232 cts_n
    I_FUSP_RXD : in slbit;              -- fusp: rs232 rx
    O_FUSP_TXD : out slbit              -- fusp: rs232 tx
  );
end component;

component n2_cram_dummy is              -- CRAM protection dummy 
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
end component;

component n2_cram_memctl_as is          -- CRAM driver (async+page mode)
  generic (
    READ0DELAY : positive := 2;         -- read word 0 delay in clock cycles
    READ1DELAY : positive := 2;         -- read word 1 delay in clock cycles
    WRITEDELAY : positive := 3);        -- write delay in clock cycles
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    REQ   : in slbit;                   -- request
    WE    : in slbit;                   -- write enable
    BUSY : out slbit;                   -- controller busy
    ACK_R : out slbit;                  -- acknowledge read
    ACK_W : out slbit;                  -- acknowledge write
    ACT_R : out slbit;                  -- signal active read
    ACT_W : out slbit;                  -- signal active write
    ADDR : in slv22;                    -- address (32 bit word address)
    BE : in slv4;                       -- byte enable
    DI : in slv32;                      -- data in  (memory view)
    DO : out slv32;                     -- data out (memory view)
    O_MEM_CE_N : out slbit;             -- cram: chip enable   (act.low)
    O_MEM_BE_N : out slv2;              -- cram: byte enables  (act.low)
    O_MEM_WE_N : out slbit;             -- cram: write enable  (act.low)
    O_MEM_OE_N : out slbit;             -- cram: output enable (act.low)
    O_MEM_ADV_N : out slbit;            -- cram: address valid (act.low)
    O_MEM_CLK : out slbit;              -- cram: clock
    O_MEM_CRE : out slbit;              -- cram: command register enable
    I_MEM_WAIT : in slbit;              -- cram: mem wait
    O_FLA_CE_N : out slbit;             -- flash ce..          (act.low)
    O_MEM_ADDR  : out slv23;            -- cram: address lines
    IO_MEM_DATA : inout slv16           -- cram: data lines
  );
end component;

end package nexys2lib;
