-- $Id: serport.vhd 314 2010-07-09 17:38:41Z mueller $
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
-- Package Name:   serport
-- Description:    serial port interface components
--
-- Dependencies:   -
-- Tool versions:  xst 8.1, 8.2, 9.1, 9.2, 11.4; ghdl 0.18-0.26
-- Revision History: 
-- Date         Rev Version  Comment
-- 2010-04-10   276   1.2    add clock divider constant defs
-- 2007-10-22    88   1.1    renames (in prev revs); remove std_logic_unsigned
-- 2007-06-03    45   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

package serport is

-- clock divider constants assume 50 MHz clock

  constant serport_clkdiv_009600 : integer := 5208-1; -- 50000000/  9600=5208.33
  constant serport_clkdiv_019200 : integer := 2604-1; -- 50000000/ 19200=2604.16
  constant serport_clkdiv_038400 : integer := 1302-1; -- 50000000/ 38400=1302.08
  constant serport_clkdiv_057600 : integer :=  868-1; -- 50000000/ 57600= 868.05
  constant serport_clkdiv_115200 : integer :=  434-1; -- 50000000/115200= 434.02
  constant serport_clkdiv_230400 : integer :=  217-1; -- 50000000/230400= 217.01
  constant serport_clkdiv_460800 : integer :=  109-1; -- 50000000/460800= 108.51
  constant serport_clkdiv_500000 : integer :=  100-1; -- 50000000/500000= 100
  constant serport_clkdiv_576000 : integer :=   87-1; -- 50000000/576000=  86.80
  constant serport_clkdiv_921600 : integer :=   54-1; -- 50000000/921600=  54.25
  constant serport_clkdiv_1M     : integer :=   50-1; -- 50000000/1M    =  50
  constant serport_clkdiv_2M     : integer :=   24-1; -- 50000000/2M    =  25

component serport_uart_rxtx is          -- serial port uart: rx+tx combo
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
end component;

component serport_uart_rx is            -- serial port uart: receive part
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
    RXACT : out slbit                   -- receiver active
  );
end component;

component serport_uart_tx is            -- serial port uart: transmit part
  generic (
    CDWIDTH : positive := 13);          -- clk divider width
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    CLKDIV : in slv(CDWIDTH-1 downto 0); -- clock divider setting
    TXSD : out slbit;                   -- transmit serial data (uart view)
    TXDATA : in slv8;                   -- transmit data in
    TXENA : in slbit;                   -- transmit data enable
    TXBUSY : out slbit                  -- transmit busy
  );
end component;

component serport_uart_rxtx_ab is       -- serial port uart: rx+tx+autobaud
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
    ABDONE : out slbit                  -- autobaud resync done
  );
end component;

component serport_uart_autobaud is      -- serial port uart: autobauder
  generic (
    CDWIDTH : positive := 13;           -- clk divider width
    CDINIT: natural := 15);             -- clk divider initial/reset setting
  port (
    CLK : in slbit;                     -- clock
    CE_MSEC : in slbit;                 -- 1 msec clock enable
    RESET : in slbit;                   -- reset
    RXSD : in slbit;                    -- receive serial data (uart view)
    CLKDIV : out slv(CDWIDTH-1 downto 0); -- clock divider setting
    ACT : out slbit;                    -- active; if 1 clkdiv is invalid
    DONE : out slbit                    -- resync done
  );
end component;

end serport;
