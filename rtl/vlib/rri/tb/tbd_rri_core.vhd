-- $Id: tbd_rri_core.vhd 314 2010-07-09 17:38:41Z mueller $
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
-- Module Name:    tbd_rri_core - syn
-- Description:    Wrapper for rri_core to avoid records. It has a port
--                 interface which will not be modified by xst synthesis
--                 (no records, no generic port).
--
-- Dependencies:   rri_core
--
-- To test:        rri_core
--
-- Target Devices: generic
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2007-11-24    92  8.1.03 I27  xc3s1000-4   143  309    0  166 s 7.64
-- 2007-10-27    92  9.2.02 J39  xc3s1000-4   148  320    0    - t 8.34
-- 2007-10-27    92  9.1    J30  xc3s1000-4   148  315    0    - t 8.34
-- 2007-10-27    92  8.2.03 I34  xc3s1000-4   153  302    0  162 s 7.65
-- 2007-10-27    92  8.1.03 I27  xc3s1000-4   138  306    0    - s 7.64
--
-- Tool versions:  xst 8.1, 8.2, 9.1, 9.2, 11.4; ghdl 0.18-0.26
-- Revision History: 
-- Date         Rev Version  Comment
-- 2010-05-02   287   2.2.1  ren CE_XSEC->CE_INT,RP_STAT->RB_STAT,AP_LAM->RB_LAM
--                           drop RP_IINT signal from interfaces
-- 2010-04-03   274   2.2    add CP_FLUSH for rri_core, add CE_USEC
-- 2009-03-14   197   2.1    remove records in interface to allow _ssim usage
-- 2008-08-24   162   2.0    with new rb_mreq/rb_sres interface
-- 2007-11-25    98   1.1    added RP_IINT support; use entity rather arch
--                           name to switch core/serport
-- 2007-07-02    63   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

use work.slvtypes.all;
use work.rrilib.all;

entity tbd_rri_core is                  -- rri_core tb design
                                        -- generic: ATOWIDTH=5; ITOWIDTH=6
                                        -- implements tbd_rri_gen
  port (
    CLK  : in slbit;                    -- clock
    CE_INT : in slbit;                  -- rri ito time unit clock enable
    CE_USEC : in slbit;                 -- 1 usec clock enable
    RESET  : in slbit;                  -- reset
    CP_DI : in slv9;                    -- comm port: data in
    CP_ENA : in slbit;                  -- comm port: data enable
    CP_BUSY : out slbit;                -- comm port: data busy
    CP_DO : out slv9;                   -- comm port: data out
    CP_VAL : out slbit;                 -- comm port: data valid
    CP_HOLD : in slbit;                 -- comm port: data hold
    RB_MREQ_req : out slbit;            -- rbus: request - req
    RB_MREQ_we : out slbit;             -- rbus: request - we
    RB_MREQ_initt : out slbit;          -- rbus: request - init; avoid name coll
    RB_MREQ_addr : out slv8;            -- rbus: request - addr
    RB_MREQ_din : out slv16;            -- rbus: request - din
    RB_SRES_ack : in slbit;             -- rbus: response - ack
    RB_SRES_busy : in slbit;            -- rbus: response - busy
    RB_SRES_err : in slbit;             -- rbus: response - err
    RB_SRES_dout : in slv16;            -- rbus: response - dout
    RB_LAM : in slv16;                  -- rbus: look at me
    RB_STAT : in slv3;                  -- rbus: status flags
    TXRXACT : out slbit                 -- txrx active flag
  );
end entity tbd_rri_core;


architecture syn of tbd_rri_core is

  signal CP_FLUSH : slbit := '0';
  signal RB_MREQ : rb_mreq_type := rb_mreq_init;
  signal RB_SRES : rb_sres_type := rb_sres_init;

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
  
  UUT : rri_core
    generic map (
      ATOWIDTH => 5,
      ITOWIDTH => 6)
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

  TXRXACT <= '0';
  
end syn;
