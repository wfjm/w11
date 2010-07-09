-- $Id: rri_serport.vhd 314 2010-07-09 17:38:41Z mueller $
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
-- Module Name:    rri_serport - syn
-- Description:    rri: serport adapter
--
-- Dependencies:   serport/serport_uart_rxtx_ab
--                 comlib/byte2cdata
--                 comlib/cdata2byte
--                 memlib/fifo_1c_dram
--
-- Test bench:     tb/tb_rri_serport
--
-- Target Devices: generic
-- Tool versions:  xst 8.1, 8.2, 9.1, 9.2, 11.4; ghdl 0.18-0.26
-- Revision History: 
-- Date         Rev Version  Comment
-- 2010-06-06   301   2.3    use NCOMM=4 (new eop,nak commas)
-- 2010-06-03   300   2.2.1  use FAWIDTH=5 
-- 2010-05-02   287   2.2    drop RTSFLUSH generic
-- 2010-04-18   279   2.1    rewrite flow control, drop RTSFBUF generic
-- 2010-04-03   274   2.0    flow control interfaces: RTSFLUSH, CTS_N, RTS_N
-- 2007-06-24    60   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

use work.slvtypes.all;
use work.genlib.all;
use work.memlib.all;
use work.comlib.all;
use work.serport.all;
use work.rrilib.all;

entity rri_serport is                   -- rri serport adapter
  generic (
    CPREF : slv4 :=  "1000";            -- comma prefix
    FAWIDTH : positive :=  5;           -- rx fifo address port width
    CDWIDTH : positive := 13;           -- clk divider width
    CDINIT : natural   := 15);          -- clk divider initial/reset setting
  port (
    CLK  : in slbit;                    -- clock
    CE_USEC : in slbit;                 -- 1 usec clock enable
    CE_MSEC : in slbit;                 -- 1 msec clock enable
    RESET : in slbit;                   -- reset
    RXSD : in slbit;                    -- receive serial data (board view)
    TXSD : out slbit;                   -- transmit serial data (board view)
    CTS_N : in slbit := '0';            -- clear to send   (act.low, board view)
    RTS_N : out slbit;                  -- request to send (act.low, board view)
    CP_DI : out slv9;                   -- comm port: data in
    CP_ENA : out slbit;                 -- comm port: data enable
    CP_BUSY : in slbit;                 -- comm port: data busy
    CP_DO : in slv9;                    -- comm port: data out
    CP_VAL : in slbit;                  -- comm port: data valid
    CP_HOLD : out slbit;                -- comm port: data hold
    CP_FLUSH : in slbit := '0'          -- comm port: data flush
  );
end rri_serport;


architecture syn of rri_serport is

  signal LRESET : slbit := '0';
  signal RXDATA : slv8 := (others=>'0');
  signal RXVAL : slbit := '0';
  signal TXDATA : slv8 := (others=>'0');
  signal TXENA : slbit := '0';
  signal TXBUSY : slbit := '0';
  signal ABACT : slbit := '0';
  signal FIFO_DI : slv9 := (others=>'0');
  signal FIFO_ENA : slbit := '0';
  signal FIFO_BUSY : slbit := '0';
  signal FIFO_SIZE : slv(FAWIDTH downto 0) := (others=>'0');
  signal CD2B_HOLD : slbit := '0';

  signal R_FIFOBLOCK : slbit := '0';       -- fifo block flag  
  signal FLUSH_PULSE : slbit := '0';       -- rri flush as 2-3 usec pulse

  constant NCOMM : positive := 4;

begin

  UART : serport_uart_rxtx_ab           -- uart, rx+tx+autobauder combo
  generic map (
    CDWIDTH => CDWIDTH,
    CDINIT  => CDINIT)
  port map (
    CLK     => CLK,
    CE_MSEC => CE_MSEC,
    RESET   => RESET,
    RXSD    => RXSD,
    RXDATA  => RXDATA,
    RXVAL   => RXVAL,
    RXERR   => open,
    RXACT   => open,
    TXSD    => TXSD,
    TXDATA  => TXDATA,
    TXENA   => TXENA,
    TXBUSY  => TXBUSY,
    ABACT   => ABACT,
    ABDONE  => open
  );

  LRESET <= RESET or ABACT;
  
  B2CD : byte2cdata                     -- byte stream -> 9bit comma,data
  generic map (
    CPREF => CPREF,
    NCOMM => NCOMM)
  port map (
    CLK   => CLK,
    RESET => LRESET,
    DI    => RXDATA,
    ENA   => RXVAL,
    BUSY  => open,
    DO    => FIFO_DI,
    VAL   => FIFO_ENA,
    HOLD  => FIFO_BUSY
  );

  CD2B : cdata2byte                     -- 9bit comma,data -> byte stream
  generic map (
    CPREF => CPREF,
    NCOMM => NCOMM)
  port map (
    CLK   => CLK,
    RESET => LRESET,
    DI    => CP_DO,
    ENA   => CP_VAL,
    BUSY  => CP_HOLD,
    DO    => TXDATA,
    VAL   => TXENA,
    HOLD  => CD2B_HOLD
  );

  FIFO : fifo_1c_dram                   -- fifo, 1 clock, dram based
  generic map (
    AWIDTH => FAWIDTH,
    DWIDTH => 9)
  port map (
    CLK   => CLK,
    RESET => LRESET,
    DI    => FIFO_DI,
    ENA   => FIFO_ENA,
    BUSY  => FIFO_BUSY,
    DO    => CP_DI,
    VAL   => CP_ENA,
    HOLD  => CP_BUSY,
    SIZE  => FIFO_SIZE
  );

-- re-write later, use RB_MREQ internal init to set parameters which
-- control the flush logic.
--
--DOFLUSH: if RTSFLUSH generate
--
--  PGEN : timer
--  generic map (
--    TWIDTH => 1,
--    RETRIG => true)
--  port map (
--    CLK   => CLK,
--    CE    => CE_USEC,
--    DELAY => "1",
--    START => CP_FLUSH,
--    STOP  => RESET,
--    BUSY  => FLUSH_PULSE
--  );
--end generate DOFLUSH;

  proc_fifoblock: process (CLK)
  begin

    if CLK'event and CLK='1' then
      if unsigned(FIFO_SIZE) >= 3*2**(FAWIDTH-2) then   -- more than 3/4 full
        R_FIFOBLOCK <= '1';                               -- block
      elsif unsigned(FIFO_SIZE) < 2**(FAWIDTH-1) then   -- less than 1/2 full
        R_FIFOBLOCK <= '0';                               -- unblock
      end if;
    end if;

  end process proc_fifoblock;

  RTS_N     <= R_FIFOBLOCK or FLUSH_PULSE;
  
  CD2B_HOLD <= TXBUSY or CTS_N;
  
end syn;
