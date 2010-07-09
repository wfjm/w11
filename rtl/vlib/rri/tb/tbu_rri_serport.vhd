-- $Id: tbu_rri_serport.vhd 314 2010-07-09 17:38:41Z mueller $
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
-- Module Name:    tbu_rri_serport - syn
-- Description:    Wrapper for rri_core plus rri_serport to avoid records. It
--                 has a port interface which will not be modified by xst
--                 synthesis (no records, no generic port).
--
-- Dependencies:   rri_core
--                 rri_serport
--
-- To test:        rri_serport
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
-- Tool versions:  xst 8.1, 8.2, 9.1, 9.2, 11.4; ghdl 0.18-0.26
-- Revision History: 
-- Date         Rev Version  Comment
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
use ieee.std_logic_arith.all;

use work.slvtypes.all;
use work.rrilib.all;

entity tbu_rri_serport is               -- rri core+serport combo
  port (
    CLK  : in slbit;                    -- clock
    CE_INT : in slbit;                  -- rri ito time unit clock enable
    CE_USEC : in slbit;                 -- 1 usec clock enable
    CE_MSEC : in slbit;                 -- 1 msec clock enable
    RESET  : in slbit;                  -- reset
    RXSD : in slbit;                    -- receive serial data (board view)
    TXSD : out slbit;                   -- transmit serial data (board view)
    RB_MREQ_req : out slbit;            -- rbus: request - req
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
end entity tbu_rri_serport;


architecture syn of tbu_rri_serport is

  signal RB_MREQ : rb_mreq_type := rb_mreq_init;
  signal RB_SRES : rb_sres_type := rb_sres_init;

  signal CTS_N : slbit := '0';
  signal RTS_N : slbit := '0';

  signal CP_DI : slv9 := (others=>'0');
  signal CP_ENA : slbit := '0';
  signal CP_BUSY : slbit := '0';
  signal CP_DO : slv9 := (others=>'0');
  signal CP_VAL : slbit := '0';
  signal CP_HOLD : slbit := '0';
  signal CP_FLUSH : slbit := '0';
  
begin

  RB_MREQ_req  <= RB_MREQ.req;
  RB_MREQ_we   <= RB_MREQ.we;
  RB_MREQ_initt<= RB_MREQ.init;
  RB_MREQ_addr <= RB_MREQ.addr;
  RB_MREQ_din  <= RB_MREQ.din;

  RB_SRES.ack  <= RB_SRES_ack;
  RB_SRES.busy <= RB_SRES_busy;
  RB_SRES.err  <= RB_SRES_err;
  RB_SRES.dout <= RB_SRES_dout;
  
  CORE : rri_core
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
      RB_MREQ  => RB_MREQ,
      RB_SRES  => RB_SRES,
      RB_LAM   => RB_LAM,
      RB_STAT  => RB_STAT
    );

  SERPORT : rri_serport
    generic map (
      CPREF    => "1000",
      CDWIDTH  => 13,
      CDINIT   =>  1)        -- NOTE: change also CLKDIV in tbd_rri_serport !!
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
  
end syn;
