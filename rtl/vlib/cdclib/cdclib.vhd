-- $Id: cdclib.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2016-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Package Name:   cdclib
-- Description:    clock domain crossing components
--
-- Dependencies:   -
-- Tool versions:  viv 2016.1-2017.2; ghdl 0.33-0.34
-- Revision History: 
-- Date         Rev Version  Comment
-- 2019-01-02  1101   1.0.2  cdc_vector_s0,cdc_pulse interface changed
-- 2016-06-11   774   1.0.1  add cdc_signal_s1_as; add INIT generic
-- 2016-04-02   757   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

package cdclib is

component cdc_signal_s1 is              -- cdc for signal (2 stage)
  generic (
    INIT : slbit := '0');               -- initial state
  port (
    CLKO : in slbit;                    -- O|output clock
    DI   : in slbit;                    -- I|input data
    DO   : out slbit                    -- O|output data
  );
end component;

component cdc_signal_s1_as is           -- cdc for signal (2 stage), asyn input
  generic (
    INIT : slbit := '0');               -- initial state
  port (
    CLKO : in slbit;                    -- O|output clock
    DI   : in slbit;                    -- I|input data
    DO   : out slbit                    -- O|output data
  );
end component;

component cdc_vector_s0 is              -- cdc for vector (1 stage)
  generic (
    DWIDTH : positive := 16);           -- data port width
  port (
    CLKO : in slbit;                    -- O|output clock
    ENA  : in slbit := '1';             -- O|capture enable
    DI   : in slv(DWIDTH-1 downto 0);   -- I|input data
    DO   : out slv(DWIDTH-1 downto 0)   -- O|output data
  );
end component;

component cdc_vector_s1 is              -- cdc for vector (2 stage)
  generic (
    DWIDTH : positive := 16);           -- data port width
  port (
    CLKO : in slbit;                    -- O|output clock
    DI   : in slv(DWIDTH-1 downto 0);   -- I|input data
    DO   : out slv(DWIDTH-1 downto 0)   -- O|output data
  );
end component;

component cdc_pulse is                  -- clock domain crossing for a pulse
  generic (
    POUT_SINGLE : boolean := false;     -- if true: single cycle pout
    BUSY_WACK : boolean := false;       -- if true: busy waits for ack
    INIT : slbit := '0');               -- initial state
  port (
    CLKM : in slbit;                    -- M|clock master
    RESET : in slbit := '0';            -- M|reset
    CLKS : in slbit;                    -- S|clock slave
    PIN : in slbit;                     -- M|pulse in
    BUSY : out slbit;                   -- M|busy
    POUT : out slbit                    -- S|pulse out
  );
end component;

component cdc_value is                  -- cdc for value (slow change)
  generic (
    DWIDTH : positive := 16);           -- data port width
  port (
    CLKI : in slbit;                    -- I|input clock
    CLKO : in slbit;                    -- O|output clock
    DI   : in slv(DWIDTH-1 downto 0);   -- I|input data
    DO   : out slv(DWIDTH-1 downto 0);  -- O|output data
    UPDT : out slbit                    -- O|output data updated
  );
end component;

end package cdclib;
