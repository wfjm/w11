-- $Id: serport_uart_rxtx_ab.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2007-2016 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    serport_uart_rxtx_ab - syn
-- Description:    serial port UART - transmitter-receiver + autobauder
--
-- Dependencies:   serport_uart_autobaud
--                 serport_uart_rxtx
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  ise 8.2-14.7; viv 2014.4-2016.2; ghdl 0.18-0.33
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2015-04-12   666 14.7  131013 xc6slx16-2   100  142    0   48 s  6.2
-- 2010-12-25   348 12.1    M53d xc3s1000-4    99  197    -  124 s  9.8
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-02-01   641   1.2    add CLKDIV_F for autobaud;
-- 2011-10-22   417   1.1.1  now numeric_std clean
-- 2010-12-26   348   1.1    add ABCLKDIV port for clock divider setting
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
    ABCLKDIV : out slv(CDWIDTH-1 downto 0); -- autobaud clock divider setting
    ABCLKDIV_F : out slv3                   -- autobaud clock divider fraction
  );
end serport_uart_rxtx_ab;

architecture syn of serport_uart_rxtx_ab is
  
  signal CLKDIV : slv(CDWIDTH-1 downto 0) := slv(to_unsigned(0, CDWIDTH));
  signal CLKDIV_F : slv3 := (others=>'0');
  signal ABACT_L : slbit := '0';        -- local readable copy of ABACT
  signal UART_RESET : slbit := '0';
  
begin

  AB : serport_uart_autobaud
    generic map (
      CDWIDTH => CDWIDTH,
      CDINIT  => CDINIT)
    port map (
      CLK      => CLK,
      CE_MSEC  => CE_MSEC,
      RESET    => RESET,
      RXSD     => RXSD,
      CLKDIV   => CLKDIV,
      CLKDIV_F => CLKDIV_F,
      ACT      => ABACT_L,
      DONE     => ABDONE
    );

  UART_RESET <= ABACT_L or RESET;
  ABACT      <= ABACT_L;
  ABCLKDIV   <= CLKDIV;
  ABCLKDIV_F <= CLKDIV_F;

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
