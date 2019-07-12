-- $Id: bpgenrbuslib.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2013-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Package Name:   bpgenrbuslib
-- Description:    Generic Board/Part components using rbus
-- 
-- Dependencies:   -
-- Tool versions:  ise 12.1-14.7; viv 2014.4-2019.1; ghdl 0.26-0.35
-- Revision History: 
-- Date         Rev Version  Comment
-- 2017-06-11   912   1.3.2  add sn_humanio_emu_rbus
-- 2017-06-05   907   1.3.1  rgbdrv_analog_rbus: add ACTLOW generic
-- 2016-02-20   734   1.3    add rgbdrv_analog_rbus
-- 2015-01-25   637   1.2    add generics to sn_humanio_rbus
-- 2014-08-15   583   1.1    rb_mreq addr now 16 bit
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
    RB_ADDR : slv16 := x"fef0");
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
    SWIDTH : positive := 8;             -- SWI port width
    BWIDTH : positive := 4;             -- BTN port width
    LWIDTH : positive := 8;             -- LED port width
    DCWIDTH : positive := 2;            -- digit counter width (2 or 3)
    DEBOUNCE : boolean := true;         -- instantiate debouncer for SWI,BTN
    RB_ADDR : slv16 := x"fef0");
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit := '0';            -- reset
    CE_MSEC : in slbit;                 -- 1 ms clock enable
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : out rb_sres_type;         -- rbus: response
    SWI : out slv(SWIDTH-1 downto 0);   -- switch settings, debounced
    BTN : out slv(BWIDTH-1 downto 0);   -- button settings, debounced
    LED : in slv(LWIDTH-1 downto 0);    -- led data
    DSP_DAT : in slv(4*(2**DCWIDTH)-1 downto 0);   -- display data
    DSP_DP : in slv((2**DCWIDTH)-1 downto 0);      -- display decimal points
    I_SWI : in slv(SWIDTH-1 downto 0);  -- pad-i: switches
    I_BTN : in slv(BWIDTH-1 downto 0);  -- pad-i: buttons
    O_LED : out slv(LWIDTH-1 downto 0); -- pad-o: leds
    O_ANO_N : out slv((2**DCWIDTH)-1 downto 0); -- pad-o: disp: anodes (act.low)
    O_SEG_N : out slv8                         -- pad-o: disp: segments (act.low)
  );
end component;

component sn_humanio_demu_rbus is       -- human i/o swi,btn,led only /w rbus
  generic (
    DEBOUNCE : boolean := true;         -- instantiate debouncer for SWI,BTN
    RB_ADDR : slv16 := x"fef0");
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

component sn_humanio_emu_rbus is        -- sn_humanio rbus emulator
  generic (
    SWIDTH : positive := 8;             -- SWI port width
    BWIDTH : positive := 4;             -- BTN port width
    LWIDTH : positive := 8;             -- LED port width
    DCWIDTH : positive := 2;            -- digit counter width (2 or 3)
    RB_ADDR : slv16 := x"fef0");
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit := '0';            -- reset
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : out rb_sres_type;         -- rbus: response
    SWI : out slv(SWIDTH-1 downto 0);   -- switch settings, debounced
    BTN : out slv(BWIDTH-1 downto 0);   -- button settings, debounced
    LED : in slv(LWIDTH-1 downto 0);    -- led data
    DSP_DAT : in slv(4*(2**DCWIDTH)-1 downto 0);   -- display data
    DSP_DP : in slv((2**DCWIDTH)-1 downto 0)       -- display decimal points
  );
end component;

component rgbdrv_analog_rbus is         -- rgb analog from rbus
  generic (
    DWIDTH : positive := 8;             -- dimmer width
    ACTLOW : slbit := '0';              -- invert output polarity
    RB_ADDR : slv16 := x"0000");
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit := '0';            -- reset
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : out rb_sres_type;         -- rbus: response
    RGBCNTL : in slv3;                  -- rgb control
    DIMCNTL : in slv(DWIDTH-1 downto 0);-- dim control
    O_RGBLED : out slv3                 -- pad-o: rgb led
  );
end component;

end package bpgenrbuslib;
