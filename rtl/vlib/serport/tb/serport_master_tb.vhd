-- $Id: serport_master_tb.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2015-2018 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    serport_master_tb - sim
-- Description:    serial port: serial port module, master side (SIM only!)
--
-- Dependencies:   serport_uart_rxtx_ab_tb
--                 serport_xonrx_tb
--                 serport_xontx_tb
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  ghdl 0.31-0.34
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2018-12-16  1087   1.1    add 100 ps RXSD,TXSD delay to allow clock jitter
-- 2016-01-03   724   1.0    Initial version (copied from serport_master)

------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;

entity serport_master_tb is             -- serial port module, 1 clock domain
  generic (
    CDWIDTH : positive := 13);          -- clk divider width
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    CLKDIV : in slv(CDWIDTH-1 downto 0); -- clock divider setting
    ENAXON : in slbit := '0';           -- enable xon/xoff handling
    ENAESC : in slbit := '0';           -- enable xon/xoff escaping
    RXDATA : out slv8;                  -- receiver data out
    RXVAL : out slbit;                  -- receiver data valid
    RXERR : out slbit;                  -- receiver data error (frame error)
    RXOK : in slbit := '1';             -- rx channel ok
    TXDATA : in slv8;                   -- transmit data in
    TXENA : in slbit;                   -- transmit data enable
    TXBUSY : out slbit;                 -- transmit busy
    RXSD : in slbit;                    -- receive serial data (uart view)
    TXSD : out slbit;                   -- transmit serial data (uart view)
    RXRTS_N : out slbit;                -- receive rts (uart view, act.low)
    TXCTS_N : in slbit := '0'           -- transmit cts (uart view, act.low)
  );
end serport_master_tb;


architecture sim of serport_master_tb is
  
  signal UART_RXDATA : slv8 := (others=>'0');
  signal UART_RXVAL  : slbit := '0';
  signal UART_TXDATA : slv8 := (others=>'0');
  signal UART_TXENA  : slbit := '0';
  signal UART_TXBUSY : slbit := '0';

  signal XONTX_TXENA  : slbit := '0';
  signal XONTX_TXBUSY : slbit := '0';

  signal UART_RXSD : slbit := '0';
  signal UART_TXSD : slbit := '0';

  signal TXOK : slbit := '0';
  
begin

  UART : entity work.serport_uart_rxtx_tb   -- uart, rx+tx combo
  generic map (
    CDWIDTH => CDWIDTH)
  port map (
    CLK        => CLK,
    RESET      => RESET,
    CLKDIV     => CLKDIV,
    RXSD       => UART_RXSD,
    RXDATA     => UART_RXDATA,
    RXVAL      => UART_RXVAL,
    RXERR      => RXERR,
    RXACT      => open,
    TXSD       => UART_TXSD,
    TXDATA     => UART_TXDATA,
    TXENA      => UART_TXENA,
    TXBUSY     => UART_TXBUSY
  );

  -- add some minor (100 ps) delay in the serial data path.
  -- this makes transmission immune against small clock jitter between test
  -- bench and UUT (e.g. from sfs re-phasing done differently in tb and UUT).
  
  TXSD      <= UART_TXSD after 100 ps;
  UART_RXSD <= RXSD      after 100 ps;
  
  XONRX : entity work.serport_xonrx_tb      --  xon/xoff logic rx path
  port map (
    CLK         => CLK,
    RESET       => RESET,
    ENAXON      => ENAXON,
    ENAESC      => ENAESC,
    UART_RXDATA => UART_RXDATA,
    UART_RXVAL  => UART_RXVAL,
    RXDATA      => RXDATA,
    RXVAL       => RXVAL,
    RXHOLD      => '0',
    RXOVR       => open,
    TXOK        => TXOK
  );

  XONTX : entity work.serport_xontx_tb      --  xon/xoff logic tx path
  port map (
    CLK         => CLK,
    RESET       => RESET,
    ENAXON      => ENAXON,
    ENAESC      => ENAESC,
    UART_TXDATA => UART_TXDATA,
    UART_TXENA  => XONTX_TXENA,
    UART_TXBUSY => XONTX_TXBUSY,
    TXDATA      => TXDATA,
    TXENA       => TXENA,
    TXBUSY      => TXBUSY,
    RXOK        => RXOK,
    TXOK        => TXOK
  );  

  RXRTS_N <= not RXOK;

  proc_cts: process (TXCTS_N, XONTX_TXENA, UART_TXBUSY)
  begin
    if TXCTS_N = '0' then               -- transmit cts asserted
      UART_TXENA   <= XONTX_TXENA;
      XONTX_TXBUSY <= UART_TXBUSY;
    else                                -- transmit cts not asserted
      UART_TXENA   <= '0';
      XONTX_TXBUSY <= '1';
    end if;
  end process proc_cts;

end sim;
