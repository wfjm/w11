-- $Id: bpgenrbuslib.vhd 476 2013-01-26 22:23:53Z mueller $
--
-- Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Package Name:   bpgenrbuslib
-- Description:    Generic Board/Part components using rbus
-- 
-- Dependencies:   -
-- Tool versions:  12.1, 13.3; ghdl 0.26-0.29
-- Revision History: 
-- Date         Rev Version  Comment
-- 2013-01-26   476   1.0    Initial version (extracted from bpgenlib)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.rblib.all;

package bpgenrbuslib is

component bp_swibtnled_rbus is          -- swi,btn,led handling /w rbus icept
  generic (
    SWIDTH : positive := 4;             -- SWI port width
    BWIDTH : positive := 4;             -- BTN port width
    LWIDTH : positive := 4;             -- LED port width
    DEBOUNCE : boolean := true;         -- instantiate debouncer for SWI,BTN
    RB_ADDR : slv8 := slv(to_unsigned(2#10000000#,8)));
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit := '0';            -- reset
    CE_MSEC : in slbit;                 -- 1 ms clock enable
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : out rb_sres_type;         -- rbus: response
    SWI : out slv(SWIDTH-1 downto 0);   -- switch settings, debounced
    BTN : out slv(BWIDTH-1 downto 0);   -- button settings, debounced
    LED : in slv(LWIDTH-1 downto 0);    -- led data
    I_SWI : in slv(SWIDTH-1 downto 0);  -- pad-i: switches
    I_BTN : in slv(BWIDTH-1 downto 0);  -- pad-i: buttons
    O_LED : out slv(LWIDTH-1 downto 0)  -- pad-o: leds
  );
end component;

component sn_humanio_rbus is            -- human i/o handling /w rbus intercept
  generic (
    BWIDTH : positive := 4;             -- BTN port width
    DEBOUNCE : boolean := true;         -- instantiate debouncer for SWI,BTN
    RB_ADDR : slv8 := slv(to_unsigned(2#10000000#,8)));
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit := '0';            -- reset
    CE_MSEC : in slbit;                 -- 1 ms clock enable
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : out rb_sres_type;         -- rbus: response
    SWI : out slv8;                     -- switch settings, debounced
    BTN : out slv(BWIDTH-1 downto 0);   -- button settings, debounced
    LED : in slv8;                      -- led data
    DSP_DAT : in slv16;                 -- display data
    DSP_DP : in slv4;                   -- display decimal points
    I_SWI : in slv8;                    -- pad-i: switches
    I_BTN : in slv(BWIDTH-1 downto 0);  -- pad-i: buttons
    O_LED : out slv8;                   -- pad-o: leds
    O_ANO_N : out slv4;                 -- pad-o: 7 seg disp: anodes   (act.low)
    O_SEG_N : out slv8                  -- pad-o: 7 seg disp: segments (act.low)
  );
end component;

component sn_humanio_demu_rbus is       -- human i/o swi,btn,led only /w rbus
  generic (
    DEBOUNCE : boolean := true;         -- instantiate debouncer for SWI,BTN
    RB_ADDR : slv8 := slv(to_unsigned(2#10000000#,8)));
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit := '0';            -- reset
    CE_MSEC : in slbit;                 -- 1 ms clock enable
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : out rb_sres_type;         -- rbus: response
    SWI : out slv8;                     -- switch settings, debounced
    BTN : out slv4;                     -- button settings, debounced
    LED : in slv8;                      -- led data
    DSP_DAT : in slv16;                 -- display data
    DSP_DP : in slv4;                   -- display decimal points
    I_SWI : in slv8;                    -- pad-i: switches
    I_BTN : in slv6;                    -- pad-i: buttons
    O_LED : out slv8                    -- pad-o: leds
  );
end component;

end package bpgenrbuslib;
