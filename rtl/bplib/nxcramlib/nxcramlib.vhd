-- $Id: nxcramlib.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2011-2016 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Package Name:   nxcramlib
-- Description:    Nexys 2/3 CRAM controllers
-- 
-- Dependencies:   -
-- Tool versions:  ise 11.4-14.7; viv 2014.4-2016.2; ghdl 0.26-0.33
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2016-07-16   788   1.1    add cram_(read0|read1|write)delay functions
-- 2011-11-26   433   1.0    Initial version (extracted from nexys2lib)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

package nxcramlib is
  
pure function cram_delay(clk_mhz : positive;
                         delay_ps : positive) return positive;
pure function cram_read0delay(clk_mhz : positive) return positive;
pure function cram_read1delay(clk_mhz : positive) return positive;
pure function cram_writedelay(clk_mhz : positive) return positive;

constant cram_read0delay_ps : positive := 80000;   -- initial read delay
constant cram_read1delay_ps : positive := 30000;   -- page read delay
constant cram_writedelay_ps : positive := 75000;   -- write delay

component nx_cram_dummy is              -- CRAM protection dummy 
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
end component;

component nx_cram_memctl_as is          -- CRAM controller (async+page mode)
  generic (
    READ0DELAY : positive := 4;         -- read word 0 delay in clock cycles
    READ1DELAY : positive := 2;         -- read word 1 delay in clock cycles
    WRITEDELAY : positive := 4);        -- write delay in clock cycles
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
    O_MEM_ADDR  : out slv23;            -- cram: address lines
    IO_MEM_DATA : inout slv16           -- cram: data lines
  );
end component;

end package nxcramlib;

-- ----------------------------------------------------------------------------
package body nxcramlib is

-- -------------------------------------
pure function cram_delay(               -- calculate delay in clock cycles
  clk_mhz : positive;                     -- clock frequency in MHz
  delay_ps : positive)                    -- delay in ps
  return positive is
  variable period_ps : natural := 0;       -- clk period in ps
begin
  period_ps := 1000000 / clk_mhz;
  return (delay_ps + period_ps - 10) / period_ps;
end function cram_delay;

-- -------------------------------------
pure function cram_read0delay(          -- read0 delay in clock cycles
  clk_mhz : positive)                     -- clock frequency in MHz
  return positive is
begin
  return cram_delay(clk_mhz, cram_read0delay_ps);
end function cram_read0delay;

-- -------------------------------------
pure function cram_read1delay(          -- read1 delay in clock cycles
  clk_mhz : positive)                     -- clock frequency in MHz
  return positive is
begin
  return cram_delay(clk_mhz, cram_read1delay_ps);
end function cram_read1delay;

-- -------------------------------------
pure function cram_writedelay(          -- write delay in clock cycles
  clk_mhz : positive)                     -- clock frequency in MHz
  return positive is
begin
  return cram_delay(clk_mhz, cram_writedelay_ps);
end function cram_writedelay;

end package body nxcramlib;
