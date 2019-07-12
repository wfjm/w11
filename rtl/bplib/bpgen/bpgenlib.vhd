-- $Id: bpgenlib.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2011-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Package Name:   bpgenlib
-- Description:    Generic Board/Part components
-- 
-- Dependencies:   -
-- Tool versions:  ise 12.1-14.7; viv 2014.4-2018.2; ghdl 0.26-0.34
-- Revision History: 
-- Date         Rev Version  Comment
-- 2018-12-16  1086   1.2.3  add s7_cmt_1ce1ce
-- 2018-08-11  1038   1.2.2  add rgbdrv_3x2mux
-- 2017-06-05   907   1.2.1  rgbdrv_analog: add ACTLOW generic
-- 2016-02-27   737   1.2    add rgbdrv entity
-- 2015-01-24   637   1.1.2  add generics to sn_humanio and sn_7segctl
-- 2013-09-21   534   1.1.1  add bp_rs232_4l4l_iob
-- 2013-01-26   476   1.1    moved rbus depended components to bpgenrbuslib
-- 2013-01-06   472   1.0.7  add sn_humanio_demu_rbus
-- 2011-11-16   426   1.0.6  now numeric_std clean
-- 2011-10-10   413   1.0.5  add sn_humanio_demu
-- 2011-08-07   404   1.0.4  add RELAY generic for bp_rs232_2l4l_iob
-- 2011-08-06   403   1.0.3  add RESET port for bp_rs232_2l4l_iob
-- 2011-07-09   391   1.0.2  move in bp_rs232_2l4l_iob from s3boardlib
-- 2011-07-08   390   1.0.1  move in sn_(4x7segctl|humanio*) from s3boardlib
-- 2011-07-01   386   1.0    Initial version (with rs232_iob's and bp_swibtnled)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;

package bpgenlib is

component bp_rs232_2line_iob is         -- iob's for 2 line rs232 (RXD,TXD)
  port (
    CLK : in slbit;                     -- clock
    RXD : out slbit;                    -- receive data (board view)
    TXD : in slbit;                     -- transmit data (board view)
    I_RXD : in slbit;                   -- pad-i: receive data (board view)
    O_TXD : out slbit                   -- pad-o: transmit data (board view)
  );
end component;

component bp_rs232_4line_iob is         -- iob's for 4 line rs232 (w/ RTS,CTS)
  port (
    CLK : in slbit;                     -- clock
    RXD : out slbit;                    -- receive data (board view)
    TXD : in slbit;                     -- transmit data (board view)
    CTS_N : out slbit;                  -- clear to send   (act. low)
    RTS_N : in slbit;                   -- request to send (act. low)
    I_RXD : in slbit;                   -- pad-i: receive data (board view)
    O_TXD : out slbit;                  -- pad-o: transmit data (board view)
    I_CTS_N : in slbit;                 -- pad-i: clear to send   (act. low)
    O_RTS_N : out slbit                 -- pad-o: request to send (act. low)
  );
end component;

component bp_rs232_2l4l_iob is          -- iob's for dual 2l+4l rs232, w/ select
  generic (
    RELAY : boolean := false);          -- add a relay stage towards IOB's
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit := '0';            -- reset
    SEL : in slbit;                     -- select, '0' for port 0
    RXD : out slbit;                    -- receive data (board view)
    TXD : in slbit;                     -- transmit data (board view)
    CTS_N : out slbit;                  -- clear to send   (act. low)
    RTS_N : in slbit;                   -- request to send (act. low)
    I_RXD0 : in slbit;                  -- pad-i: p0: receive data (board view)
    O_TXD0 : out slbit;                 -- pad-o: p0: transmit data (board view)
    I_RXD1 : in slbit;                  -- pad-i: p1: receive data (board view)
    O_TXD1 : out slbit;                 -- pad-o: p1: transmit data (board view)
    I_CTS1_N : in slbit;                -- pad-i: p1: clear to send   (act. low)
    O_RTS1_N : out slbit                -- pad-o: p1: request to send (act. low)
  );
end component;

component bp_rs232_4l4l_iob is          -- iob's for dual 4l+4l rs232, w/ select
  generic (
    RELAY : boolean := false);          -- add a relay stage towards IOB's
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit := '0';            -- reset
    SEL : in slbit;                     -- select, '0' for port 0
    RXD : out slbit;                    -- receive data (board view)
    TXD : in slbit;                     -- transmit data (board view)
    CTS_N : out slbit;                  -- clear to send   (act. low)
    RTS_N : in slbit;                   -- request to send (act. low)
    I_RXD0 : in slbit;                  -- pad-i: p0: receive data (board view)
    O_TXD0 : out slbit;                 -- pad-o: p0: transmit data (board view)
    I_CTS0_N : in slbit;                -- pad-i: p0: clear to send   (act. low)
    O_RTS0_N : out slbit;               -- pad-o: p0: request to send (act. low)
    I_RXD1 : in slbit;                  -- pad-i: p1: receive data (board view)
    O_TXD1 : out slbit;                 -- pad-o: p1: transmit data (board view)
    I_CTS1_N : in slbit;                -- pad-i: p1: clear to send   (act. low)
    O_RTS1_N : out slbit                -- pad-o: p1: request to send (act. low)
  );
end component;

component bp_swibtnled is               -- generic SWI, BTN and LED handling
  generic (
    SWIDTH : positive := 4;             -- SWI port width
    BWIDTH : positive := 4;             -- BTN port width
    LWIDTH : positive := 4;             -- LED port width
    DEBOUNCE : boolean := true);        -- instantiate debouncer for SWI,BTN
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit := '0';            -- reset
    CE_MSEC : in slbit;                 -- 1 ms clock enable
    SWI : out slv(SWIDTH-1 downto 0);   -- switch settings, debounced
    BTN : out slv(BWIDTH-1 downto 0);   -- button settings, debounced
    LED : in slv(LWIDTH-1 downto 0);    -- led data
    I_SWI : in slv(SWIDTH-1 downto 0);  -- pad-i: switches
    I_BTN : in slv(BWIDTH-1 downto 0);  -- pad-i: buttons
    O_LED : out slv(LWIDTH-1 downto 0)  -- pad-o: leds
  );
end component;

component sn_7segctl is                 -- 7 segment display controller
  generic (
    DCWIDTH : positive := 2;            -- digit counter width (2 or 3)
    CDWIDTH : positive := 6);           -- clk divider width (must be >= 5)
  port (
    CLK : in slbit;                     -- clock
    DIN : in slv(4*(2**DCWIDTH)-1 downto 0);  -- data                16 or 32
    DP : in slv((2**DCWIDTH)-1 downto 0);     -- decimal points       4 or  8
    ANO_N : out slv((2**DCWIDTH)-1 downto 0); -- anodes    (act.low)  4 or  8
    SEG_N : out slv8                          -- segements (act.low)
  );
end component;

component sn_humanio is                 -- human i/o handling: swi,btn,led,dsp
  generic (
    SWIDTH : positive := 8;             -- SWI port width
    BWIDTH : positive := 4;             -- BTN port width
    LWIDTH : positive := 8;             -- LED port width
    DCWIDTH : positive := 2;            -- digit counter width (2 or 3)
    DEBOUNCE : boolean := true);        -- instantiate debouncer for SWI,BTN
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit := '0';            -- reset
    CE_MSEC : in slbit;                 -- 1 ms clock enable
    SWI : out slv(SWIDTH-1 downto 0);   -- switch settings, debounced
    BTN : out slv(BWIDTH-1 downto 0);   -- button settings, debounced
    LED : in slv(LWIDTH-1 downto 0);    -- led data
    DSP_DAT : in slv(4*(2**DCWIDTH)-1 downto 0);   -- display data
    DSP_DP : in slv((2**DCWIDTH)-1 downto 0);      -- display decimal points
    I_SWI : in slv(SWIDTH-1 downto 0);  -- pad-i: switches
    I_BTN : in slv(BWIDTH-1 downto 0);  -- pad-i: buttons
    O_LED : out slv(LWIDTH-1 downto 0); -- pad-o: leds
    O_ANO_N : out slv((2**DCWIDTH)-1 downto 0); -- pad-o: disp: anodes (act.low)
    O_SEG_N : out slv8                        -- pad-o: disp: segments (act.low)
  );
end component;

component sn_humanio_demu is            -- human i/o handling: swi,btn,led only
  generic (
    DEBOUNCE : boolean := true);        -- instantiate debouncer for SWI,BTN
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit := '0';            -- reset
    CE_MSEC : in slbit;                 -- 1 ms clock enable
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

component rgbdrv_master is              -- rgbled driver: master
  generic (
    DWIDTH : positive := 8);            -- dimmer width
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit := '0';            -- reset
    CE_USEC : in slbit;                 -- 1 us clock enable
    RGBCNTL : out slv3;                   -- rgb control
    DIMCNTL : out slv(DWIDTH-1 downto 0)  -- dim control
  );
end component;

component rgbdrv_analog is              -- rgbled driver: analog channel
  generic (
    DWIDTH : positive := 8;             -- dimmer width
    ACTLOW : slbit := '0');             -- invert output polarity
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit := '0';            -- reset
    RGBCNTL : in slv3;                  -- rgb control
    DIMCNTL : in slv(DWIDTH-1 downto 0);-- dim control
    DIMR : in slv(DWIDTH-1 downto 0);   -- dim red
    DIMG : in slv(DWIDTH-1 downto 0);   -- dim green
    DIMB : in slv(DWIDTH-1 downto 0);   -- dim blue
    O_RGBLED : out slv3                 -- pad-o: rgb led
  );
end component;

component rgbdrv_binary is              -- rgbled driver: binary channel
  generic (
    DWIDTH : positive := 8);            -- dimmer width
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit := '0';            -- reset
    RGBCNTL : in slv3;                  -- rgb control
    DIMCNTL : in slv(DWIDTH-1 downto 0);-- dim control
    DIM : in slv(DWIDTH-1 downto 0);    -- dim
    ENARGB : in slv3;                   -- enable [0] red  [1] green [2] blue
    O_RGBLED : out slv3                 -- pad-o: rgb led
  );
end component;

component rgbdrv_3x4mux is              -- rgbled driver: mux three 4bit inputs
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit := '0';            -- reset
    CE_USEC : in slbit;                 -- 1 us clock enable
    DATR : in slv4;                     -- red   data
    DATG : in slv4;                     -- green data
    DATB : in slv4;                     -- blue  data
    O_RGBLED0 : out slv3;               -- pad-o: rgb led 0
    O_RGBLED1 : out slv3;               -- pad-o: rgb led 1
    O_RGBLED2 : out slv3;               -- pad-o: rgb led 2
    O_RGBLED3 : out slv3                -- pad-o: rgb led 3
  );
end component;

component rgbdrv_3x2mux is              -- rgbled driver: mux three 2bit inputs
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit := '0';            -- reset
    CE_USEC : in slbit;                 -- 1 us clock enable
    DATR : in slv2;                     -- red   data
    DATG : in slv2;                     -- green data
    DATB : in slv2;                     -- blue  data
    O_RGBLED0 : out slv3;               -- pad-o: rgb led 0
    O_RGBLED1 : out slv3                -- pad-o: rgb led 1
  );
end component;

component s7_cmt_1ce1ce  is             -- clocking block: 2 clk+CEs
  generic (
    CLKIN_PERIOD  : real := 10.0;       -- CLKIN period (def is 10.0 ns)
    CLKIN_JITTER  : real := 0.01;       -- CLKIN jitter (def is 10 ps)
    STARTUP_WAIT  : boolean := false;   -- hold FPGA startup till LOCKED
    CLK0_VCODIV   : positive := 1;      -- clk0: vco clock divide
    CLK0_VCOMUL   : positive := 1;      -- clk0: vco clock multiply 
    CLK0_OUTDIV   : positive := 1;      -- clk0: output divide
    CLK0_GENTYPE  : string := "PLL";    -- clk0: PLL or MMCM
    CLK0_CDUWIDTH : positive :=   7;    -- clk0: usec clock divider width
    CLK0_USECDIV  : positive :=  50;    -- clk0: divider ratio for usec pulse
    CLK0_MSECDIV  : positive := 1000;   -- clk0: divider ratio for msec pulse
    CLK1_VCODIV   : positive := 1;      -- clk1: vco clock divide
    CLK1_VCOMUL   : positive := 1;      -- clk1: vco clock multiply 
    CLK1_OUTDIV   : positive := 1;      -- clk1: output divide
    CLK1_GENTYPE  : string := "MMCM";   -- clk1: PLL or MMCM
    CLK1_CDUWIDTH : positive :=   7;    -- clk1: usec clock divider width
    CLK1_USECDIV  : positive :=  50;    -- clk1: divider ratio for usec pulse
    CLK1_MSECDIV  : positive := 1000);  -- clk1: divider ratio for msec pulse
  port (
    CLKIN    : in slbit;                -- clock input
    CLK0     : out slbit;               -- clk0: clock output
    CE0_USEC : out slbit;               -- clk0: usec pulse
    CE0_MSEC : out slbit;               -- clk0: msec pulse
    CLK1     : out slbit;               -- clk1: clock output
    CE1_USEC : out slbit;               -- clk1: usec pulse
    CE1_MSEC : out slbit;               -- clk1: msec pulse
    LOCKED   : out slbit                -- all PLL/MMCM locked
  );
end component;

component s7_cmt_1ce1ce2c  is           -- clocking block: 2 clk+CEs; 2 clk
  generic (
    CLKIN_PERIOD  : real := 10.0;       -- CLKIN period (def is 10.0 ns)
    CLKIN_JITTER  : real := 0.01;       -- CLKIN jitter (def is 10 ps)
    STARTUP_WAIT  : boolean := false;   -- hold FPGA startup till LOCKED
    CLK0_VCODIV   : positive := 1;      -- clk0: vco clock divide
    CLK0_VCOMUL   : positive := 1;      -- clk0: vco clock multiply 
    CLK0_OUTDIV   : positive := 1;      -- clk0: output divide
    CLK0_GENTYPE  : string := "PLL";    -- clk0: PLL or MMCM
    CLK0_CDUWIDTH : positive :=   7;    -- clk0: usec clock divider width
    CLK0_USECDIV  : positive :=  50;    -- clk0: divider ratio for usec pulse
    CLK0_MSECDIV  : positive := 1000;   -- clk0: divider ratio for msec pulse
    CLK1_VCODIV   : positive := 1;      -- clk1: vco clock divide
    CLK1_VCOMUL   : positive := 1;      -- clk1: vco clock multiply 
    CLK1_OUTDIV   : positive := 1;      -- clk1: output divide
    CLK1_GENTYPE  : string := "MMCM";   -- clk1: PLL or MMCM
    CLK1_CDUWIDTH : positive :=   7;    -- clk1: usec clock divider width
    CLK1_USECDIV  : positive :=  50;    -- clk1: divider ratio for usec pulse
    CLK1_MSECDIV  : positive := 1000;   -- clk1: divider ratio for msec pulse
    CLK23_VCODIV  : positive := 1;      -- clk2+3: vco clock divide
    CLK23_VCOMUL  : positive := 1;      -- clk2+3: vco clock multiply 
    CLK2_OUTDIV   : positive := 1;      -- clk2: output divide
    CLK3_OUTDIV   : positive := 1;      -- clk3: output divide
    CLK23_GENTYPE : string := "PLL");   -- clk2+3: PLL or MMCM
  port (
    CLKIN    : in slbit;                -- clock input
    CLK0     : out slbit;               -- clk0: clock output
    CE0_USEC : out slbit;               -- clk0: usec pulse
    CE0_MSEC : out slbit;               -- clk0: msec pulse
    CLK1     : out slbit;               -- clk1: clock output
    CE1_USEC : out slbit;               -- clk1: usec pulse
    CE1_MSEC : out slbit;               -- clk1: msec pulse
    CLK2     : out slbit;               -- clk2: clock output
    CLK3     : out slbit;               -- clk3: clock output
    LOCKED   : out slbit                -- all PLL/MMCM locked
  );
end component;

end package bpgenlib;
