-- $Id: genlib.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2007-2016 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Package Name:   genlib
-- Description:    some general purpose components
--
-- Dependencies:   -
-- Tool versions:  ise 8.1-14.7; viv 2014.4-2015.4; ghdl 0.18-0.33
-- Revision History: 
-- Date         Rev Version  Comment
-- 2016-04-02   757   1.1    move cdc_pulse to cdclib
-- 2016-03-25   751   1.0.10 add gray_cnt_6
-- 2012-12-29   466   1.0.9  add led_pulse_stretch
-- 2011-11-09   421   1.0.8  add cdc_pulse
-- 2010-04-17   277   1.0.7  timer: no default for START,DONE,BUSY; drop STOP
-- 2010-04-02   273   1.0.6  add timer
-- 2008-01-20   112   1.0.5  rename clkgen->clkdivce
-- 2007-12-26   106   1.0.4  added gray_cnt_(4|5|n|gen) and gray2bin_gen
-- 2007-12-25   105   1.0.3  RESET:='0' defaults
-- 2007-06-17    58   1.0.2  added debounce_gen
-- 2007-06-16    57   1.0.1  added cnt_array_dram, cnt_array_regs
-- 2007-06-03    45   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

package genlib is

component clkdivce is                   -- generate usec/msec ce pulses
  generic (
    CDUWIDTH : positive := 6;           -- usec clock divider width
    USECDIV : positive :=  50;          -- divider ratio for usec pulse
    MSECDIV : positive := 1000);        -- divider ratio for msec pulse
  port (
    CLK     : in slbit;                 -- input clock
    CE_USEC : out slbit;                -- usec pulse
    CE_MSEC : out slbit                 -- msec pulse
  );
end component;
  
component cnt_array_dram is             -- counter array, dram based
  generic (
    AWIDTH : positive := 4;             -- address width
    DWIDTH : positive := 16);           -- data width
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit := '0';            -- clear counters
    CE : in slv(2**AWIDTH-1 downto 0);  -- count enables
    ADDR : out slv(AWIDTH-1 downto 0);  -- counter address
    DATA : out slv(DWIDTH-1 downto 0);  -- counter data
    ACT : out slbit                     -- active (not reseting)
  );
end component;

component cnt_array_regs is             -- counter array, register based
  generic (
    AWIDTH : positive := 4;             -- address width
    DWIDTH : positive := 16);           -- data width
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit := '0';            -- clear counters
    CE : in slv(2**AWIDTH-1 downto 0);  -- count enables
    ADDR : in slv(AWIDTH-1 downto 0);   -- address
    DATA : out slv(DWIDTH-1 downto 0)   -- counter data
  );
end component;

component debounce_gen is               -- debounce, generic vector
  generic (
    CWIDTH : positive := 2;             -- clock interval counter width
    CEDIV : positive := 3;              -- clock interval divider
    DWIDTH : positive := 8);            -- data width
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit := '0';            -- reset
    CE_INT : in slbit;                  -- clock interval enable (usec or msec)
    DI : in slv(DWIDTH-1 downto 0);     -- data in
    DO : out slv(DWIDTH-1 downto 0)     -- data out
  );
end component;

component gray_cnt_gen is               -- gray code counter, generic vector
  generic (
    DWIDTH : positive := 4);            -- data width
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit := '0';            -- reset
    CE : in slbit := '1';               -- count enable
    DATA : out slv(DWIDTH-1 downto 0)   -- data out
  );
end component;

component gray_cnt_4 is                 -- 4 bit gray code counter (ROM based)
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit := '0';            -- reset
    CE : in slbit := '1';               -- count enable
    DATA : out slv4                     -- data out
  );
end component;

component gray_cnt_5 is                 -- 5 bit gray code counter (ROM based)
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit := '0';            -- reset
    CE : in slbit := '1';               -- count enable
    DATA : out slv5                     -- data out
  );
end component;

component gray_cnt_6 is                 -- 6 bit gray code counter (ROM based)
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit := '0';            -- reset
    CE : in slbit := '1';               -- count enable
    DATA : out slv5                     -- data out
  );
end component;

component gray_cnt_n is                 -- n bit gray code counter
  generic (
    DWIDTH : positive := 8);            -- data width
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit := '0';            -- reset
    CE : in slbit := '1';               -- count enable
    DATA : out slv(DWIDTH-1 downto 0)   -- data out
  );
end component;

component gray2bin_gen is               -- gray->bin converter, generic vector
  generic (
    DWIDTH : positive := 4);            -- data width
  port (
    DI : in slv(DWIDTH-1 downto 0);     -- gray code input
    DO : out slv(DWIDTH-1 downto 0)     -- binary code output
  );
end component;

component timer is                      -- retriggerable timer
  generic (
    TWIDTH : positive := 4;             -- timer counter width
    RETRIG : boolean := true);          -- re-triggerable true/false
  port (
    CLK : in slbit;                     -- clock
    CE : in slbit := '1';               -- clock enable
    DELAY : in slv(TWIDTH-1 downto 0) := (others=>'1');  -- timer delay
    START : in slbit;                   -- start timer
    STOP : in slbit := '0';             -- stop timer
    DONE : out slbit;                   -- mark last delay cycle
    BUSY : out slbit                    -- timer running
  );
end component;

component led_pulse_stretch is          -- pulse stretcher for leds
  port (
    CLK : in slbit;                     -- clock
    CE_INT : in slbit;                  -- pulse time unit clock enable
    RESET : in slbit := '0';            -- reset
    DIN : in slbit;                     -- data in
    POUT : out slbit                    -- pulse out
  );
end component;

end package genlib;
