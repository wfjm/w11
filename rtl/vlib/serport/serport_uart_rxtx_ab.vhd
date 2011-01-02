-- $Id: serport_uart_rxtx_ab.vhd 350 2010-12-28 16:40:11Z mueller $
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
-- Module Name:    serport_uart_rxtx_ab - syn
-- Description:    serial port UART - transmitter-receiver + autobauder
--
-- Dependencies:   serport_uart_autobaud
--                 serport_uart_rxtx
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  xst 8.1, 8.2, 9.1, 9.2, 11.4, 12.1; ghdl 0.18-0.29
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2010-12-25   348 12.1    M53d xc3s1000-4    99  197    -  124 s  9.8
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2010-12-26   348   1.1    add ABCLKDIV port for clock divider setting
-- 2007-06-24    60   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

use work.slvtypes.all;
use work.serport.all;

entity serport_uart_rxtx_ab is          -- serial port uart: rx+tx+autobaud
  generic (
    CDWIDTH : positive := 13;           -- clk divider width
    CDINIT: natural := 15);             -- clk divider initial/reset setting
  port (
    CLK : in slbit;                     -- clock
    CE_MSEC : in slbit;                 -- 1 msec clock enable
    RESET : in slbit;                   -- reset
    RXSD : in slbit;                    -- receive serial data (uart view)
    RXDATA : out slv8;                  -- receiver data out
    RXVAL : out slbit;                  -- receiver data valid
    RXERR : out slbit;                  -- receiver data error (frame error)
    RXACT : out slbit;                  -- receiver active
    TXSD : out slbit;                   -- transmit serial data (uart view)
    TXDATA : in slv8;                   -- transmit data in
    TXENA : in slbit;                   -- transmit data enable
    TXBUSY : out slbit;                 -- transmit busy
    ABACT : out slbit;                  -- autobaud active; if 1 clkdiv invalid
    ABDONE : out slbit;                 -- autobaud resync done
    ABCLKDIV : out slv(CDWIDTH-1 downto 0) -- autobaud clock divider setting
  );
end serport_uart_rxtx_ab;

architecture syn of serport_uart_rxtx_ab is
  
  signal CLKDIV : slv(CDWIDTH-1 downto 0) := conv_std_logic_vector(0, CDWIDTH);
  signal ABACT_L : slbit := '0';        -- local readable copy of ABACT
  signal UART_RESET : slbit := '0';
  
begin

  AB : serport_uart_autobaud
    generic map (
      CDWIDTH => CDWIDTH,
      CDINIT  => CDINIT)
    port map (
      CLK     => CLK,
      CE_MSEC => CE_MSEC,
      RESET   => RESET,
      RXSD    => RXSD,
      CLKDIV  => CLKDIV,
      ACT     => ABACT_L,
      DONE    => ABDONE
    );

  UART_RESET <= ABACT_L or RESET;
  ABACT      <= ABACT_L;
  ABCLKDIV   <= CLKDIV;
  
  RXTX : serport_uart_rxtx
    generic map (
      CDWIDTH => CDWIDTH)
    port map (
      CLK    => CLK,
      RESET  => UART_RESET,
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
