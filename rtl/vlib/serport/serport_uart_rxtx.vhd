-- $Id: serport_uart_rxtx.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2007-2016 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    serport_uart_rxtx - syn
-- Description:    serial port UART - transmitter + receiver
--
-- Dependencies:   serport_uart_rx
--                 serport_uart_tx
-- Test bench:     tb/tb_serport_uart_rxtx
-- Target Devices: generic
-- Tool versions:  ise 8.2-14.7; viv 2014.4-2016.2; ghdl 0.18-0.33
-- Revision History:
-- Date         Rev Version  Comment
-- 2007-06-24    60   1.0    Initial version 
------------------------------------------------------------------------------
-- NOTE: for test bench usage a copy of all serport_* entities, with _tb
-- !!!!  appended to the name, has been created in the /tb sub folder.
-- !!!!  Ensure to update the copy when this file is changed !!

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.serportlib.all;

entity serport_uart_rxtx is             -- serial port uart: rx+tx combo
  generic (
    CDWIDTH : positive := 13);          -- clk divider width
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    CLKDIV : in slv(CDWIDTH-1 downto 0); -- clock divider setting
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
end serport_uart_rxtx;

architecture syn of serport_uart_rxtx is

begin

  RX : serport_uart_rx
    generic map (
      CDWIDTH => CDWIDTH)
    port map (
      CLK    => CLK,
      RESET  => RESET,
      CLKDIV => CLKDIV,
      RXSD   => RXSD,
      RXDATA => RXDATA,
      RXVAL  => RXVAL,
      RXERR  => RXERR,
      RXACT  => RXACT
    );

  TX : serport_uart_tx
    generic map (
      CDWIDTH => CDWIDTH)
    port map (
      CLK    => CLK,
      RESET  => RESET,
      CLKDIV => CLKDIV,
      TXSD   => TXSD,
      TXDATA => TXDATA,
      TXENA  => TXENA,
      TXBUSY => TXBUSY
    );
  
end syn;
