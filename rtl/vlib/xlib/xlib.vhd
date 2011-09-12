-- $Id: xlib.vhd 389 2011-07-07 21:59:00Z mueller $
--
-- Copyright 2007-2010 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Package Name:   xlib
-- Description:    Xilinx specific components
--
-- Dependencies:   -
-- Tool versions:  xst 8.1, 8.2, 9.1, 9.2; ghdl 0.18-0.25
-- Revision History: 
-- Date         Rev Version  Comment
-- 2010-11-07   337   1.0.5  add dcm_sp_sfs
-- 2008-05-23   149   1.0.4  add iob_io(_gen)
-- 2008-05-22   148   1.0.3  add iob_keeper(_gen);
-- 2008-05-18   147   1.0.2  add PULL generic to iob_reg_io(_gen)
-- 2007-12-16   101   1.0.1  add INIT generic ports
-- 2007-12-08   100   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

package xlib is

component iob_reg_i is                  -- registered IOB, input
  generic (
    INIT : slbit := '0');               -- initial state
  port (
    CLK  : in slbit;                    -- clock
    CE   : in slbit := '1';             -- clock enable
    DI   : out slbit;                   -- input data
    PAD  : in slbit                     -- i/o pad
  );
end component;

component iob_reg_i_gen is              -- registered IOB, input, vector
  generic (
    DWIDTH : positive := 16;            -- data port width
    INIT : slbit := '0');               -- initial state
  port (
    CLK  : in slbit;                    -- clock
    CE   : in slbit := '1';             -- clock enable
    DI   : out slv(DWIDTH-1 downto 0);  -- input data
    PAD  : in slv(DWIDTH-1 downto 0)    -- i/o pad
  );
end component;

component iob_reg_o is                  -- registered IOB, output
  generic (
    INIT : slbit := '0');               -- initial state
  port (
    CLK  : in slbit;                    -- clock
    CE   : in slbit := '1';             -- clock enable
    DO   : in slbit;                    -- output data
    PAD  : out slbit                    -- i/o pad
  );
end component;

component iob_reg_o_gen is              -- registered IOB, output, vector
  generic (
    DWIDTH : positive := 16;            -- data port width
    INIT : slbit := '0');               -- initial state
  port (
    CLK  : in slbit;                    -- clock
    CE   : in slbit := '1';             -- clock enable
    DO   : in slv(DWIDTH-1 downto 0);   -- output data
    PAD  : out slv(DWIDTH-1 downto 0)   -- i/o pad
  );
end component;

component iob_reg_io is                 -- registered IOB, in/output
  generic (
    INITI : slbit := '0';               -- initial state ( in flop)
    INITO : slbit := '0';               -- initial state (out flop)
    INITE : slbit := '0';               -- initial state ( oe flop)
    PULL : string := "NONE");           -- pull-up,-down or keeper
  port (
    CLK  : in slbit;                    -- clock
    CEI  : in slbit := '1';             -- clock enable ( in flops)
    CEO  : in slbit := '1';             -- clock enable (out flops)
    OE   : in slbit;                    -- output enable
    DI   : out slbit;                   -- input data   (read from pad)
    DO   : in slbit;                    -- output data  (write  to pad)
    PAD  : inout slbit                  -- i/o pad
  );
end component;

component iob_reg_io_gen is             -- registered IOB, in/output, vector
  generic (
    DWIDTH : positive := 16;            -- data port width
    INITI : slbit := '0';               -- initial state ( in flop)
    INITO : slbit := '0';               -- initial state (out flop)
    INITE : slbit := '0';               -- initial state ( oe flop)
    PULL : string := "NONE");           -- pull-up,-down or keeper
  port (
    CLK  : in slbit;                    -- clock
    CEI  : in slbit := '1';             -- clock enable ( in flops)
    CEO  : in slbit := '1';             -- clock enable (out flops)
    OE   : in slbit;                    -- output enable
    DI   : out slv(DWIDTH-1 downto 0);  -- input data   (read from pad)
    DO   : in slv(DWIDTH-1 downto 0);   -- output data  (write  to pad)
    PAD  : inout slv(DWIDTH-1 downto 0)  -- i/o pad
  );
end component;

component iob_io is                     -- un-registered IOB, in/output
  generic (
    PULL : string := "NONE");           -- pull-up,-down or keeper
  port (
    OE   : in slbit;                    -- output enable
    DI   : out slbit;                   -- input data   (read from pad)
    DO   : in slbit;                    -- output data  (write  to pad)
    PAD  : inout slbit                  -- i/o pad
  );
end component;

component iob_io_gen is                 -- un-registered IOB, in/output, vector
  generic (
    DWIDTH : positive := 16;            -- data port width
    PULL : string := "NONE");           -- pull-up,-down or keeper
  port (
    OE   : in slbit;                    -- output enable
    DI   : out slv(DWIDTH-1 downto 0);  -- input data   (read from pad)
    DO   : in slv(DWIDTH-1 downto 0);   -- output data  (write  to pad)
    PAD  : inout slv(DWIDTH-1 downto 0)  -- i/o pad
  );
end component;

component iob_keeper is                 -- keeper for IOB
  port (
    PAD  : inout slbit                  -- i/o pad
  );
end component;

component iob_keeper_gen is             -- keeper for IOB, vector
  generic (
    DWIDTH : positive := 16);           -- data port width
  port (
    PAD  : inout slv(DWIDTH-1 downto 0)  -- i/o pad
  );
end component;

component dcm_sp_sfs is                 -- DCM_SP as 'simple freq. synthesis'
  generic (
    CLKFX_DIVIDE : positive := 2;       -- FX clock divide (1-32)
    CLKFX_MULTIPLY : positive := 2;     -- FX clock divide (2-32)
    CLKIN_PERIOD : real := 20.0);       -- CLKIN period (def is 20.0 ns)
  port (
    CLKIN : in slbit;                   -- clock input
    CLKFX : out slbit;                  -- clock output (synthesized freq.) 
    LOCKED : out slbit                  -- dcm locked
  );
end component;

end package xlib;
