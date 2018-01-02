-- $Id: serport_uart_rxtx_tb.vhd 984 2018-01-02 20:56:27Z mueller $
--
-- Copyright 2007-2016 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
-- This program is free software; you may redistribute and/or modify it under
-- the terms of the GNU General Public License as published by the Free
-- Software Foundation, either version 3, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
-- or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
-- for complete details.
--
------------------------------------------------------------------------------
-- Module Name:    serport_uart_rxtx_tb - syn
-- Description:    serial port UART - transmitter + receiver (SIM only!)
--
-- Dependencies:   serport_uart_rx_tb
--                 serport_uart_tx_tb
-- Target Devices: generic
-- Tool versions:  ghdl 0.18-0.31
-- Revision History:
-- Date         Rev Version  Comment
-- 2016-01-03   724   1.0    Initial version (copied from serport_uart_rxtx)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;

entity serport_uart_rxtx_tb is          -- serial port uart: rx+tx combo
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
end serport_uart_rxtx_tb;

architecture sim of serport_uart_rxtx_tb is

begin

  RX : entity work.serport_uart_rx_tb
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

  TX : entity work.serport_uart_tx_tb
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
  
end sim;
