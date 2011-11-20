-- $Id: rlink_base_serport.vhd 427 2011-11-19 21:04:11Z mueller $
--
-- Copyright 2010-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    rlink_base_serport - syn
-- Description:    rlink base + serport combo
--
-- Dependencies:   rlink_base
--                 rlink_serport
--
-- Test bench:     -
--
-- Target Devices: generic
-- Tool versions:  xst 11.4, 12.1; ghdl 0.26-0.29
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri ifa ofa
-- 2010-12-26   348 12.1    M53d xc3s1000-4   332  687   72  463 s 10.2   5   5
-- 2010-12-26   348 12.1    M53d xc3s1000-4   320  651   36  425 s 10.2   5   0
-- 2010-12-26   301 12.1    M53d xc3s1000-4   289  619   36  394 s  9.9   -   -
-- 2010-04-03   275 11.4    L68  xc3s1000-4   280  600   18  375 s  8.9   -   -
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-11-19   427   3.1.1  now numeric_std clean
-- 2010-12-26   348   3.1    rename from rlink_core_serport, use now rlink_base
-- 2010-12-24   347   3.0.1  rename: CP_*->RL->*
-- 2010-12-04   343   3.0    renamed rri_ -> rlink_
-- 2010-06-05   301   1.2.2  renamed _rpmon -> _rbmon
-- 2010-06-03   300   1.2.1  use FAWIDTH=5 
-- 2010-05-02   287   1.2    ren CE_XSEC->CE_INT,RP_STAT->RB_STAT,AP_LAM->RB_LAM
--                           drop RP_IINT from interfaces; drop RTSFLUSH generic
-- 2010-04-18   279   1.1    drop RTSFBUF generic
-- 2010-04-10   275   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.rblib.all;
use work.rlinklib.all;

entity rlink_base_serport is            -- rlink base+serport combo
  generic (
    ATOWIDTH : positive :=  5;          -- access timeout counter width
    ITOWIDTH : positive :=  6;          -- idle timeout counter width
    CPREF : slv4 := c_rlink_cpref;      -- comma prefix
    IFAWIDTH : natural :=  5;           -- input fifo address width  (0=none)
    OFAWIDTH : natural :=  5;           -- output fifo address width (0=none)
    ENAPIN_RLMON : integer := sbcntl_sbf_rlmon;  -- SB_CNTL for rlmon (-1=none)
    ENAPIN_RBMON : integer := sbcntl_sbf_rbmon;  -- SB_CNTL for rbmon (-1=none)
    RB_ADDR : slv8 := slv(to_unsigned(2#11111110#,8));
    CDWIDTH : positive := 13;           -- clk divider width
    CDINIT : natural   := 15);          -- clk divider initial/reset setting
  port (
    CLK  : in slbit;                    -- clock
    CE_USEC : in slbit;                 -- 1 usec clock enable
    CE_MSEC : in slbit;                 -- 1 msec clock enable
    CE_INT : in slbit := '0';           -- rlink ito time unit clock enable
    RESET  : in slbit;                  -- reset
    RXSD : in slbit;                    -- receive serial data      (board view)
    TXSD : out slbit;                   -- transmit serial data     (board view)
    CTS_N : in slbit := '0';            -- clear to send   (act.low, board view)
    RTS_N : out slbit;                  -- request to send (act.low, board view)
    RB_MREQ : out rb_mreq_type;         -- rbus: request
    RB_SRES : in rb_sres_type;          -- rbus: response
    RB_LAM : in slv16;                  -- rbus: look at me
    RB_STAT : in slv3;                  -- rbus: status flags
    RL_MONI : out rl_moni_type;         -- rlink_core: monitor port
    RL_SER_MONI : out rl_ser_moni_type  -- rlink_serport: monitor port
  );
end entity rlink_base_serport;


architecture syn of rlink_base_serport is

  signal RLB_DI : slv8 := (others=>'0');
  signal RLB_ENA : slbit := '0';
  signal RLB_BUSY : slbit := '0';
  signal RLB_DO : slv8 := (others=>'0');
  signal RLB_VAL : slbit := '0';
  signal RLB_HOLD : slbit := '0';
  signal IFIFO_SIZE : slv4 := (others=>'0');

  signal RL_MONI_L : rl_moni_type := rl_moni_init;  -- local, readable RL_MONI
  signal RB_MREQ_L : rb_mreq_type := rb_mreq_init;  -- local, readable RB_MREQ

begin
  
  BASE : rlink_base
    generic map (
      ATOWIDTH     => ATOWIDTH,
      ITOWIDTH     => ITOWIDTH,
      CPREF        => CPREF,
      IFAWIDTH     => IFAWIDTH,
      OFAWIDTH     => OFAWIDTH,
      ENAPIN_RLMON => ENAPIN_RLMON,
      ENAPIN_RBMON => ENAPIN_RBMON)
    port map (
      CLK        => CLK,
      CE_INT     => CE_INT,
      RESET      => RESET,
      RLB_DI     => RLB_DI,
      RLB_ENA    => RLB_ENA,
      RLB_BUSY   => RLB_BUSY,
      RLB_DO     => RLB_DO,
      RLB_VAL    => RLB_VAL,
      RLB_HOLD   => RLB_HOLD,
      IFIFO_SIZE => IFIFO_SIZE,
      OFIFO_SIZE => open,
      RL_MONI    => RL_MONI_L,
      RB_MREQ    => RB_MREQ_L,
      RB_SRES    => RB_SRES,
      RB_LAM     => RB_LAM,
      RB_STAT    => RB_STAT
    );

  RL_MONI <= RL_MONI_L;
  RB_MREQ <= RB_MREQ_L;
  
  SERPORT : rlink_serport
    generic map (
      RB_ADDR  => RB_ADDR,
      CDWIDTH  => CDWIDTH,
      CDINIT   => CDINIT)
    port map (
      CLK        => CLK,
      CE_USEC    => CE_USEC,
      CE_MSEC    => CE_MSEC,
      RESET      => RESET,
      RXSD       => RXSD,
      TXSD       => TXSD,
      CTS_N      => CTS_N,
      RTS_N      => RTS_N,
      RLB_DI     => RLB_DI,
      RLB_ENA    => RLB_ENA,
      RLB_BUSY   => RLB_BUSY,
      RLB_DO     => RLB_DO,
      RLB_VAL    => RLB_VAL,
      RLB_HOLD   => RLB_HOLD,
      RB_MREQ    => RB_MREQ_L,
      IFIFO_SIZE => IFIFO_SIZE,
      RL_MONI    => RL_MONI_L,
      RL_SER_MONI=> RL_SER_MONI
    );
  
end syn;
