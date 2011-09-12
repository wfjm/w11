-- $Id: rlink_serport.vhd 406 2011-08-14 21:06:44Z mueller $
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
-- Module Name:    rlink_serport - syn
-- Description:    rlink: serport adapter (serial to rlink_base)
--
-- Dependencies:   serport/serport_uart_rxtx_ab
--
-- Test bench:     tb/tb_rlink_serport
--
-- Target Devices: generic
-- Tool versions:  xst 8.1, 8.2, 9.1, 9.2, 11.4, 12.1, 13.1; ghdl 0.18-0.29
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2010-12-26   348 12.1    M53d xc3s1000-4   122  227    -  152 s  9.8
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-08-14   406   3.1.1  cleaner code for RL_SER_MONI.clkdiv assignment
-- 2010-12-25   348   3.1    re-written, is now a serial to rlink_base adapter
-- 2010-12-24   347   3.0.1  rename: CP_*->RL->*
-- 2010-12-04   343   3.0    renamed rri_ -> rlink_
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
use work.serport.all;
use work.rblib.all;
use work.rlinklib.all;

entity rlink_serport is                 -- rlink serport adapter
  generic (
    RB_ADDR : slv8 := conv_std_logic_vector(2#11111110#,8);
    CDWIDTH : positive := 13;           -- clk divider width
    CDINIT : natural   := 15);          -- clk divider initial/reset setting
  port (
    CLK  : in slbit;                    -- clock
    CE_USEC : in slbit;                 -- 1 usec clock enable
    CE_MSEC : in slbit;                 -- 1 msec clock enable
    RESET  : in slbit;                  -- reset
    RXSD : in slbit;                    -- receive serial data      (board view)
    TXSD : out slbit;                   -- transmit serial data     (board view)
    CTS_N : in slbit := '0';            -- clear to send   (act.low, board view)
    RTS_N : out slbit;                  -- request to send (act.low, board view)
    RLB_DI : out slv8;                  -- rlink 8b: data in
    RLB_ENA : out slbit;                -- rlink 8b: data enable
    RLB_BUSY : in slbit;                -- rlink 8b: data busy
    RLB_DO : in slv8;                   -- rlink 8b: data out
    RLB_VAL : in slbit;                 -- rlink 8b: data valid
    RLB_HOLD : out slbit;               -- rlink 8b: data hold
    RB_MREQ : in rb_mreq_type;          -- rbus: request (for inits only)
    IFIFO_SIZE : in slv4;               -- rlink_rlb2rb: input fifo size
    RL_MONI : in rl_moni_type;          -- rlink_core: monitor port
    RL_SER_MONI : out rl_ser_moni_type  -- rlink_serport: monitor port
  );
end rlink_serport;


architecture syn of rlink_serport is

  type regs_type is record
    flpend  : slbit;                    -- flush pending
    fldbusy : slbit;                    -- flush delay busy
    fldcnt  : slv3;                     -- flush delay counter
    flpbusy : slbit;                    -- flush pulse busy
    flpcnt  : slv3;                     -- flush pulse counter
    ffblock : slbit;                    -- fifo block
    fena    : slbit;                    -- flush enable
    fwidth  : slv3;                     -- flush pulse width
    fdelay  : slv3;                     -- flush pulse delay
    rtsoff  : slv3;                     -- rts off level (fifo high water)
    rtson   : slv3;                     -- rts on  level (fifo low water)
  end record regs_type;

  constant regs_init : regs_type := (
    '0','0',"000",                      -- flpend,fldbusy,fldcnt
    '0',"000",                          -- flpbusy,flpcnt
    '0',                                -- ffblock
    '0',                                -- fena
    "000","000",                        -- fwidth,fdelay
    "111","110"                         -- rtsoff,rtson
  );

  signal R_REGS : regs_type := regs_init;  -- state registers
  signal N_REGS : regs_type := regs_init;  -- next value state regs

  signal RXVAL : slbit := '0';
  signal RXERR : slbit := '0';
  signal RXACT : slbit := '0';
  signal TXBUSY : slbit := '0';
  signal ABACT : slbit := '0';
  signal ABDONE : slbit := '0';
  signal ABCLKDIV : slv(CDWIDTH-1 downto 0) := (others=>'0');

begin

  assert CDWIDTH<=16
    report "assert(CDWIDTH<=16): max width of UART clock divider"
    severity failure;

  UART : serport_uart_rxtx_ab           -- uart, rx+tx+autobauder combo
  generic map (
    CDWIDTH => CDWIDTH,
    CDINIT  => CDINIT)
  port map (
    CLK      => CLK,
    CE_MSEC  => CE_MSEC,
    RESET    => RESET,
    RXSD     => RXSD,
    RXDATA   => RLB_DI,
    RXVAL    => RXVAL,
    RXERR    => RXERR,
    RXACT    => RXACT,
    TXSD     => TXSD,
    TXDATA   => RLB_DO,
    TXENA    => RLB_VAL,
    TXBUSY   => TXBUSY,
    ABACT    => ABACT,
    ABDONE   => ABDONE,
    ABCLKDIV => ABCLKDIV(CDWIDTH-1 downto 0)
  );
  
  proc_regs: process (CLK)
  begin

    if CLK'event and CLK='1' then
      if RESET = '1' then
        R_REGS <= regs_init;
      else
        R_REGS <= N_REGS;
      end if;
    end if;

  end process proc_regs;

  proc_next: process (R_REGS, RB_MREQ, IFIFO_SIZE, RL_MONI, TXBUSY, CE_USEC)

    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;

  begin

    r := R_REGS;
    n := R_REGS;

    -- handle init
    if RB_MREQ.init='1' and RB_MREQ.we='0' and RB_MREQ.addr=RB_ADDR then
      n.fena   := RB_MREQ.din(c_rlink_serport_rbf_fena);
      n.fwidth := RB_MREQ.din(c_rlink_serport_rbf_fwidth);
      n.fdelay := RB_MREQ.din(c_rlink_serport_rbf_fdelay);
      n.rtsoff := RB_MREQ.din(c_rlink_serport_rbf_rtsoff);
      n.rtson  := RB_MREQ.din(c_rlink_serport_rbf_rtson);
    end if;

    -- fifo back preasure
    if IFIFO_SIZE(3)='1' or
       unsigned(IFIFO_SIZE(2 downto 0))>unsigned(r.rtsoff) then
      n.ffblock := '1';
    elsif unsigned(IFIFO_SIZE(2 downto 0)) <= unsigned(r.rtson) then
      n.ffblock := '0';
    end if;

    -- send flush pulse if
    --   eop send unless a pending attn
    --   or an attn was send
    
    if (RL_MONI.eop='1' and RL_MONI.lamp='0') or RL_MONI.attn='1' then
      n.flpend := r.fena;
    end if;

    -- flush pulse logic
    --   start delay when flpend is set
    --   re-start delay when TXBUSY=1
    --   when timer expires, clear flpend, start pulse
    
    if r.flpend='1' and (r.fldbusy='0' or TXBUSY='1') then
      n.fldbusy := '1';
      n.fldcnt  := r.fdelay;
    elsif CE_USEC='1' and r.fldbusy='1' then
      if unsigned(r.fldcnt) = 0 then
        n.flpend  := '0';
        n.fldbusy := '0';
        n.flpbusy := '1';
        n.flpcnt  := r.fwidth;
      else
        n.fldcnt := unsigned(r.fldcnt) - 1;
      end if;
    end if;

    if CE_USEC='1' and r.flpbusy='1' then
      if unsigned(r.flpcnt) = 0 then
        n.flpbusy := '0';
      else
        n.flpcnt := unsigned(r.flpcnt) - 1;
      end if;
    end if;
    
    N_REGS <= n;

  end process proc_next;
    
  RTS_N    <= R_REGS.ffblock or R_REGS.flpbusy;

  RLB_ENA  <= RXVAL;
  RLB_HOLD <= TXBUSY or CTS_N;
  
  RL_SER_MONI.rxerr  <= RXERR;
  RL_SER_MONI.rxdrop <= RXVAL and RLB_BUSY;
  RL_SER_MONI.rxact  <= RXACT;
  RL_SER_MONI.txact  <= TXBUSY;
  RL_SER_MONI.abact  <= ABACT;
  RL_SER_MONI.abdone <= ABDONE;
  
  proc_clkdiv: process (ABCLKDIV)
  begin
    RL_SER_MONI.clkdiv <= (others=>'0');
    RL_SER_MONI.clkdiv(ABCLKDIV'range) <= ABCLKDIV;
  end process proc_clkdiv;

end syn;
