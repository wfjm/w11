-- $Id: tbd_serport_uart_rxtx.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2007-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    tbd_serport_uart_rxtx - syn
-- Description:    Wrapper for serport_uart_rxtx to avoid records. It
--                 has a port interface which will not be modified by xst
--                 synthesis (no records, no generic port).
--
-- Dependencies:   serport_uart_rxtx
--
-- To test:        serport_uart_rxtx
--
-- Target Devices: generic
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2007-10-27    92  9.2.02 J39  xc3s1000-4    69  122    0    - t 9.13
-- 2007-10-27    92  9.1    J30  xc3s1000-4    69  122    0    - t 9.13
-- 2007-10-27    92  8.2.03 I34  xc3s1000-4    73  152    0   81 s 9.30
-- 2007-10-27    92  8.1.03 I27  xc3s1000-4    73  125    0    - s 9.30
--
-- Tool versions:  xst 8.2-14.7; ghdl 0.18-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2007-10-21    91   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.serportlib.all;

entity tbd_serport_uart_rxtx is         -- serial port uart [tb design]
                                        -- generic: CDWIDTH=13
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    CLKDIV : in slv13;                  -- clock divider setting
    RXSD : in slbit;                    -- receive serial data (uart view)
    RXDATA : out slv8;                  -- receiver data out
    RXVAL : out slbit;                  -- receiver data valid
    RXERR : out slbit;                  -- receiver data error (frame error)
    RXACT : out slbit;                  -- receiver active
    TXSD : out slbit;                   -- transmit serial data (uart view)
    TXDATA : in slv8;                   -- transmit data in
    TXENA : in slbit;                   -- transmit data enable
    TXBUSY : out slbit                  -- transmit busy
  );
end tbd_serport_uart_rxtx;


architecture syn of tbd_serport_uart_rxtx is

begin

  UART : serport_uart_rxtx
    generic map (
      CDWIDTH => 13)
    port map (
      CLK    => CLK,
      RESET  => RESET,
      CLKDIV => CLKDIV,
      RXSD   => RXSD,
      RXDATA => RXDATA,
      RXVAL  => RXVAL,
      RXERR  => RXERR,
      RXACT  => RXACT,
      TXSD   => TXSD,
      TXDATA => TXDATA,
      TXENA  => TXENA,
      TXBUSY => TXBUSY
    );
  
end syn;
