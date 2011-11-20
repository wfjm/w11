-- $Id: tbu_rlink_serport.vhd 427 2011-11-19 21:04:11Z mueller $
--
-- Copyright 2007-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    tbu_rlink_serport - syn
-- Description:    Wrapper for rlink_base plus rlink_serport to avoid records.
--                 It has a port interface which will not be modified by xst
--                 synthesis (no records, no generic port).
--
-- Dependencies:   rlink_base
--                 rlink_serport
--
-- To test:        rlink_serport
--
-- Target Devices: generic
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2010-04-03   274  11.4   L68  xc3s1000-4   278  588   18  366 s 9.83
-- 2007-10-27    92  9.2.02 J39  xc3s1000-4   273  547   18    - t 9.65
-- 2007-10-27    92  9.1    J30  xc3s1000-4   273  545   18    - t 9.65
-- 2007-10-27    92  8.2.03 I34  xc3s1000-4   283  594   18  323 s 10.3
-- 2007-10-27    92  8.1.03 I27  xc3s1000-4   285  596   18    - s 9.32
--
-- Tool versions:  xst 8.2, 9.1, 9.2, 11.4, 12.1, 13.1; ghdl 0.18-0.29
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-11-19   427   3.1.2  now numeric_std clean
-- 2010-12-28   350   3.1.1  use CLKDIV/CDINIT=0;
-- 2010-12-26   348   3.1    use rlink_base now; add RTS/CTS ports
-- 2010-12-24   347   3.0.1  rename: CP_*->RL->*
-- 2010-12-05   343   3.0    rri->rlink renames; port to rbus V3 protocol;
-- 2010-06-03   300   2.2.3  use default FAWIDTH for rri_core_serport
-- 2010-05-02   287   2.2.2  ren CE_XSEC->CE_INT,RP_STAT->RB_STAT,AP_LAM->RB_LAM
--                           drop RP_IINT from interfaces; drop RTSFLUSH generic
-- 2010-04-18   279   2.2.1  drop RTSFBUF generic for rri_serport
-- 2010-04-03   274   2.2    add CP_FLUSH, add rri_serport handshake logic
-- 2009-03-14   197   2.1    remove records in interface to allow _ssim usage
-- 2008-08-24   162   2.0    with new rb_mreq/rb_sres interface
-- 2007-11-24    98   1.1    added RP_IINT support
-- 2007-07-02    63   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.rblib.all;
use work.rlinklib.all;

entity tbu_rlink_serport is             -- rlink core+serport combo
  port (
    CLK  : in slbit;                    -- clock
    CE_INT : in slbit;                  -- rlink ito time unit clock enable
    CE_USEC : in slbit;                 -- 1 usec clock enable
    CE_MSEC : in slbit;                 -- 1 msec clock enable
    RESET  : in slbit;                  -- reset
    RXSD : in slbit;                    -- receive serial data      (board view)
    TXSD : out slbit;                   -- transmit serial data     (board view)
    CTS_N : in slbit;                   -- clear to send   (act.low, board view)
    RTS_N : out slbit;                  -- request to send (act.low, board view)
    RB_MREQ_aval : out slbit;           -- rbus: request - aval
    RB_MREQ_re : out slbit;             -- rbus: request - re
    RB_MREQ_we : out slbit;             -- rbus: request - we
    RB_MREQ_initt: out slbit;           -- rbus: request - init; avoid name coll
    RB_MREQ_addr : out slv8;            -- rbus: request - addr
    RB_MREQ_din : out slv16;            -- rbus: request - din
    RB_SRES_ack : in slbit;             -- rbus: response - ack
    RB_SRES_busy : in slbit;            -- rbus: response - busy
    RB_SRES_err : in slbit;             -- rbus: response - err
    RB_SRES_dout : in slv16;            -- rbus: response - dout
    RB_LAM : in slv16;                  -- rbus: look at me
    RB_STAT : in slv3                   -- rbus: status flags
  );
end entity tbu_rlink_serport;


architecture syn of tbu_rlink_serport is

  constant CDWIDTH : positive := 13;
  constant c_cdinit : natural := 0;   -- NOTE: change in tbd_rlink_serport !!

  signal RB_MREQ : rb_mreq_type := rb_mreq_init;
  signal RB_SRES : rb_sres_type := rb_sres_init;

  signal RLB_DI : slv8 := (others=>'0');
  signal RLB_ENA : slbit := '0';
  signal RLB_BUSY : slbit := '0';
  signal RLB_DO : slv8 := (others=>'0');
  signal RLB_VAL : slbit := '0';
  signal RLB_HOLD : slbit := '0';
  signal IFIFO_SIZE : slv4 := (others=>'0');
  signal RL_MONI : rl_moni_type := rl_moni_init;
  
begin

  RB_MREQ_aval <= RB_MREQ.aval;
  RB_MREQ_re   <= RB_MREQ.re;
  RB_MREQ_we   <= RB_MREQ.we;
  RB_MREQ_initt<= RB_MREQ.init;
  RB_MREQ_addr <= RB_MREQ.addr;
  RB_MREQ_din  <= RB_MREQ.din;

  RB_SRES.ack  <= RB_SRES_ack;
  RB_SRES.busy <= RB_SRES_busy;
  RB_SRES.err  <= RB_SRES_err;
  RB_SRES.dout <= RB_SRES_dout;

  BASE : rlink_base
    generic map (
      ATOWIDTH     =>  5,
      ITOWIDTH     =>  6,
      CPREF        =>  c_rlink_cpref,
      IFAWIDTH     =>  5,
      OFAWIDTH     =>  0,               -- no output fifo
      ENAPIN_RLMON => -1,               -- no monitors (both are instantiated in
      ENAPIN_RBMON => -1)               --   tbd_rlink_serport for ssim avail.)
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
      RL_MONI    => RL_MONI,
      RB_MREQ    => RB_MREQ,
      RB_SRES    => RB_SRES,
      RB_LAM     => RB_LAM,
      RB_STAT    => RB_STAT
    );

  SERPORT : rlink_serport
    generic map (
      RB_ADDR  => slv(to_unsigned(2#11111110#,8)),
      CDWIDTH  => CDWIDTH,
      CDINIT   => c_cdinit)
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
      RB_MREQ    => RB_MREQ,
      IFIFO_SIZE => IFIFO_SIZE,
      RL_MONI    => RL_MONI,
      RL_SER_MONI=> open
    );
  
end syn;
