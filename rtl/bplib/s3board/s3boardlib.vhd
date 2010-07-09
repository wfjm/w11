-- $Id: s3boardlib.vhd 314 2010-07-09 17:38:41Z mueller $
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
-- Package Name:   s3boardlib
-- Description:    S3BOARD components
-- 
-- Dependencies:   -
-- Tool versions:  xst 8.1, 8.2, 9.1, 9.2, 11.4; ghdl 0.18-0.26
-- Revision History: 
-- Date         Rev Version  Comment
-- 2010-06-03   300   1.3    add s3_humanio_rri (now needs rrilib)
-- 2010-05-21   292   1.2.2  rename _PM1_ -> _FUSP_
-- 2010-05-16   291   1.2.1  rename memctl_s3sram -> s3_sram_memctl; _usp->_fusp
-- 2010-05-01   286   1.2    added s3board_usp_aif (base+pm1_rs232)
-- 2010-04-17   278   1.1.6  rename, prefix dispdrv,sram_summy with s3_;
--                           add s3_rs232_iob_(int|ext|int_ext)
-- 2010-04-11   276   1.1.5  add DEBOUNCE for s3_humanio
-- 2010-04-10   275   1.1.4  add s3_humanio
-- 2008-02-17   117   1.1.3  memctl_s3sram: use req,we interface
-- 2008-01-20   113   1.1.2  rename memdrv -> memctl_s3sram
-- 2007-12-16   101   1.1.1  use _N for active low
-- 2007-12-09   100   1.1    add sram memory signals; sram_dummy; memdrv
-- 2007-09-23    84   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

use work.slvtypes.all;
use work.rrilib.all;

package s3boardlib is

component s3board_aif is                -- S3BOARD, abstract iface, base
  port (
    CLK : in slbit;                     -- clock
    I_RXD : in slbit;                   -- receive data (board view)
    O_TXD : out slbit;                  -- transmit data (board view)
    I_SWI : in slv8;                    -- s3 switches
    I_BTN : in slv4;                    -- s3 buttons
    O_LED : out slv8;                   -- s3 leds
    O_ANO_N : out slv4;                 -- 7 segment disp: anodes   (act.low)
    O_SEG_N : out slv8;                 -- 7 segment disp: segments (act.low)
    O_MEM_CE_N : out slv2;              -- sram: chip enables  (act.low)
    O_MEM_BE_N : out slv4;              -- sram: byte enables  (act.low)
    O_MEM_WE_N : out slbit;             -- sram: write enable  (act.low)
    O_MEM_OE_N : out slbit;             -- sram: output enable (act.low)
    O_MEM_ADDR  : out slv18;            -- sram: address lines
    IO_MEM_DATA : inout slv32           -- sram: data lines
  );
end component;

component s3board_fusp_aif is           -- S3BOARD, abstract iface, base+fusp
  port (
    CLK : in slbit;                     -- clock
    I_RXD : in slbit;                   -- receive data (board view)
    O_TXD : out slbit;                  -- transmit data (board view)
    I_SWI : in slv8;                    -- s3 switches
    I_BTN : in slv4;                    -- s3 buttons
    O_LED : out slv8;                   -- s3 leds
    O_ANO_N : out slv4;                 -- 7 segment disp: anodes   (act.low)
    O_SEG_N : out slv8;                 -- 7 segment disp: segments (act.low)
    O_MEM_CE_N : out slv2;              -- sram: chip enables  (act.low)
    O_MEM_BE_N : out slv4;              -- sram: byte enables  (act.low)
    O_MEM_WE_N : out slbit;             -- sram: write enable  (act.low)
    O_MEM_OE_N : out slbit;             -- sram: output enable (act.low)
    O_MEM_ADDR  : out slv18;            -- sram: address lines
    IO_MEM_DATA : inout slv32;          -- sram: data lines
    O_FUSP_RTS_N : out slbit;           -- fusp: rs232 rts_n
    I_FUSP_CTS_N : in slbit;            -- fusp: rs232 cts_n
    I_FUSP_RXD : in slbit;              -- fusp: rs232 rx
    O_FUSP_TXD : out slbit              -- fusp: rs232 tx
  );
end component;

component s3_dispdrv is                 -- 7 segment display driver
  generic (
    CDWIDTH : positive := 6);           -- clk divider width (must be >= 5)
  port (
    CLK : in slbit;                     -- clock
    DIN : in slv16;                     -- data
    DP : in slv4;                       -- decimal points
    ANO_N : out slv4;                   -- anodes    (act.low)
    SEG_N : out slv8                    -- segements (act.low)
  );
end component;

component s3_humanio is                 -- human i/o handling: swi,btn,led,dsp
  generic (
    DEBOUNCE : boolean := true);        -- instantiate debouncer for SWI,BTN
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    CE_MSEC : in slbit;                 -- 1 ms clock enable
    SWI : out slv8;                     -- switch settings, debounced
    BTN : out slv4;                     -- button settings, debounced
    LED : in slv8;                      -- led data
    DSP_DAT : in slv16;                 -- display data
    DSP_DP : in slv4;                   -- display decimal points
    I_SWI : in slv8;                    -- pad-i: switches
    I_BTN : in slv4;                    -- pad-i: buttons
    O_LED : out slv8;                   -- pad-o: leds
    O_ANO_N : out slv4;                 -- pad-o: 7 seg disp: anodes   (act.low)
    O_SEG_N : out slv8                  -- pad-o: 7 seg disp: segments (act.low)
  );
end component;

component s3_humanio_rri is             -- human i/o handling with rri intercept
  generic (
    DEBOUNCE : boolean := true;         -- instantiate debouncer for SWI,BTN
    RB_ADDR : slv8 := conv_std_logic_vector(2#10000000#,8));
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    CE_MSEC : in slbit;                 -- 1 ms clock enable
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : out rb_sres_type;         -- rbus: response
    SWI : out slv8;                     -- switch settings, debounced
    BTN : out slv4;                     -- button settings, debounced
    LED : in slv8;                      -- led data
    DSP_DAT : in slv16;                 -- display data
    DSP_DP : in slv4;                   -- display decimal points
    I_SWI : in slv8;                    -- pad-i: switches
    I_BTN : in slv4;                    -- pad-i: buttons
    O_LED : out slv8;                   -- pad-o: leds
    O_ANO_N : out slv4;                 -- pad-o: 7 seg disp: anodes   (act.low)
    O_SEG_N : out slv8                  -- pad-o: 7 seg disp: segments (act.low)
  );
end component;

component s3_rs232_iob_int is           -- iob's for internal rs232
  port (
    CLK : in slbit;                     -- clock
    RXD : out slbit;                    -- receive data (board view)
    TXD : in slbit;                     -- transmit data (board view)
    I_RXD : in slbit;                   -- pad-i: receive data (board view)
    O_TXD : out slbit                   -- pad-o: transmit data (board view)
  );
end component;

component s3_rs232_iob_ext is           -- iob's for external rs232 (Pmod)
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

component s3_rs232_iob_int_ext is       -- iob's for int+ext rs232, with select
  port (
    CLK : in slbit;                     -- clock
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

component s3_sram_dummy is              -- SRAM protection dummy 
  port (
    O_MEM_CE_N : out slv2;              -- sram: chip enables  (act.low)
    O_MEM_BE_N : out slv4;              -- sram: byte enables  (act.low)
    O_MEM_WE_N : out slbit;             -- sram: write enable  (act.low)
    O_MEM_OE_N : out slbit;             -- sram: output enable (act.low)
    O_MEM_ADDR  : out slv18;            -- sram: address lines
    IO_MEM_DATA : inout slv32           -- sram: data lines
  );
end component;

component s3_sram_memctl is             -- SRAM driver
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
    ADDR : in slv18;                    -- address
    BE : in slv4;                       -- byte enable
    DI : in slv32;                      -- data in  (memory view)
    DO : out slv32;                     -- data out (memory view)
    O_MEM_CE_N : out slv2;              -- sram: chip enables  (act.low)
    O_MEM_BE_N : out slv4;              -- sram: byte enables  (act.low)
    O_MEM_WE_N : out slbit;             -- sram: write enable  (act.low)
    O_MEM_OE_N : out slbit;             -- sram: output enable (act.low)
    O_MEM_ADDR  : out slv18;            -- sram: address lines
    IO_MEM_DATA : inout slv32           -- sram: data lines
  );
end component;

end s3boardlib;
