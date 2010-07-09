-- $Id: rri_core_serport.vhd 314 2010-07-09 17:38:41Z mueller $
--
-- Copyright 2010- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    rri_core_serport - syn
-- Description:    rri: core + serport combo, with cpmon and rbmon
--
-- Dependencies:   rri_serport
--                 rri_core
--                 rritb_cpmon_sb  [sim only]
--                 rritb_rbmon_sb  [sim only]
--
-- Test bench:     -
--
-- Target Devices: generic
-- Tool versions:  xst 11.4; ghdl 0.26
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2010-04-03   275  11.4    L68 xc3s1000-4   280  600   18  375 s  9.8
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2010-06-05   301   1.2.2  renamed _rpmon -> _rbmon
-- 2010-06-03   300   1.2.1  use FAWIDTH=5 
-- 2010-05-02   287   1.2    ren CE_XSEC->CE_INT,RP_STAT->RB_STAT,AP_LAM->RB_LAM
--                           drop RP_IINT from interfaces; drop RTSFLUSH generic
-- 2010-04-18   279   1.1    drop RTSFBUF generic
-- 2010-04-10   275   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

use work.slvtypes.all;
use work.rrilib.all;
-- synthesis translate_off
use work.rritblib.all;
-- synthesis translate_on

entity rri_core_serport is              -- rri, core+serport with cpmon+rbmon
  generic (
    ATOWIDTH : positive :=  5;          -- access timeout counter width
    ITOWIDTH : positive :=  6;          -- idle timeout counter width
    FAWIDTH : positive :=  5;           -- rx fifo address port width
    CDWIDTH : positive := 13;           -- clk divider width
    CDINIT : natural   := 15);          -- clk divider initial/reset setting
  port (
    CLK  : in slbit;                    -- clock
    CE_USEC : in slbit;                 -- 1 usec clock enable
    CE_MSEC : in slbit;                 -- 1 msec clock enable
    CE_INT : in slbit := '0';           -- rri ito time unit clock enable
    RESET  : in slbit;                  -- reset
    RXSD : in slbit;                    -- receive serial data      (board view)
    TXSD : out slbit;                   -- transmit serial data     (board view)
    CTS_N : in slbit := '0';            -- clear to send   (act.low, board view)
    RTS_N : out slbit;                  -- request to send (act.low, board view)
    RB_MREQ : out rb_mreq_type;         -- rbus: request
    RB_SRES : in rb_sres_type;          -- rbus: response
    RB_LAM : in slv16;                  -- rbus: look at me
    RB_STAT : in slv3                   -- rbus: status flags
  );
end entity rri_core_serport;


architecture syn of rri_core_serport is

  signal CP_DI : slv9 := (others=>'0');
  signal CP_ENA : slbit := '0';
  signal CP_BUSY : slbit := '0';
  signal CP_DO : slv9 := (others=>'0');
  signal CP_VAL : slbit := '0';
  signal CP_HOLD : slbit := '0';
  signal CP_FLUSH : slbit := '0';

  signal RB_MREQ_L : rb_mreq_type := rb_mreq_init;  -- local, readable RB_MREQ

begin
  
  SER2RRI : rri_serport
    generic map (
      CPREF    => "1000",
      FAWIDTH  => FAWIDTH,
      CDWIDTH  => CDWIDTH,
      CDINIT   => CDINIT)
    port map (
      CLK      => CLK,
      CE_USEC  => CE_USEC,
      CE_MSEC  => CE_MSEC,
      RESET    => RESET,
      RXSD     => RXSD,
      TXSD     => TXSD,
      CTS_N    => CTS_N,
      RTS_N    => RTS_N,
      CP_DI    => CP_DI,
      CP_ENA   => CP_ENA,
      CP_BUSY  => CP_BUSY,
      CP_DO    => CP_DO,
      CP_VAL   => CP_VAL,
      CP_HOLD  => CP_HOLD,
      CP_FLUSH => CP_FLUSH
    );

  RRI : rri_core
    generic map (
      ATOWIDTH => ATOWIDTH,
      ITOWIDTH => ITOWIDTH)
    port map (
      CLK      => CLK,
      CE_INT   => CE_INT,
      RESET    => RESET,
      CP_DI    => CP_DI,
      CP_ENA   => CP_ENA,
      CP_BUSY  => CP_BUSY,
      CP_DO    => CP_DO,
      CP_VAL   => CP_VAL,
      CP_HOLD  => CP_HOLD,
      CP_FLUSH => CP_FLUSH,
      RB_MREQ  => RB_MREQ_L,
      RB_SRES  => RB_SRES,
      RB_LAM   => RB_LAM,
      RB_STAT  => RB_STAT
    );

  -- vhdl'93 unfortunately doesn't allow to read a signal bound to an out port
  -- because RB_MREQ is read by the monitors, an extra internal
  -- signal must be used. This will not be needed with vhdl'2000 anymore
  
  RB_MREQ <= RB_MREQ_L;
  
-- synthesis translate_off
  CPMON : rritb_cpmon_sb
    generic map (
      DWIDTH => CP_DI'length,
      ENAPIN => 15)
    port map (
      CLK     => CLK,
      CP_DI   => CP_DI,
      CP_ENA  => CP_ENA,
      CP_BUSY => CP_BUSY,
      CP_DO   => CP_DO,
      CP_VAL  => CP_VAL,
      CP_HOLD => CP_HOLD
    );

  RBMON : rritb_rbmon_sb
    generic map (
      DBASE  => 8,
      ENAPIN => 14)
    port map (
      CLK     => CLK,
      RB_MREQ => RB_MREQ_L,
      RB_SRES => RB_SRES,
      RB_LAM  => RB_LAM,
      RB_STAT => RB_STAT
    );
-- synthesis translate_on

end syn;
