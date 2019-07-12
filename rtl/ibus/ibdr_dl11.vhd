-- $Id: ibdr_dl11.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2008-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    ibdr_dl11 - syn
-- Description:    ibus dev(rem): DL11-A/B
--
-- Dependencies:   ib_rlim_slv
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  ise 8.2-14.7; viv 2017.2; ghdl 0.18-0.35
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2010-10-17   333 12.1    M53d xc3s1000-4    39  126    0   72 s  7.6
-- 2009-07-12   233 10.1.03 K39  xc3s1000-4    38  119    0   69 s  6.3
-- 2009-07-11   232 10.1.03 K39  xc3s1000-4    23   61    0   40 s  5.5
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2019-04-27  1140   1.3.3  drop rbuf.rrdy, set rbuf.[rx]size0 instead
-- 2019-04-24  1138   1.3.2  add rcsr.ir and xcsr.ir (intreq monitors)
-- 2019-04-14  1131   1.3.1  RLIM_CEV now slv8
-- 2019-04-07  1127   1.3    for dl11_buf compat: xbuf.val in bit 15 and 8;
--                           use rbuf instead xbuf for rdry reporting; remove
--                           maintenance mode; use ib_rlim_slv; drop CE_USEC
-- 2011-11-18   427   1.2.2  now numeric_std clean
-- 2010-10-23   335   1.2.1  rename RRI_LAM->RB_LAM;
-- 2010-10-17   333   1.2    use ibus V2 interface
-- 2010-06-11   303   1.1    use IB_MREQ.racc instead of RRI_REQ
-- 2009-07-12   233   1.0.5  add RESET, CE_USEC port; implement input rate limit
-- 2008-08-22   161   1.0.6  use iblib; add EI_ACK_* to proc_next sens. list
-- 2008-05-09   144   1.0.5  use intreq flop, use EI_ACK
-- 2008-03-22   128   1.0.4  rename xdone -> xval (no functional change)
-- 2008-01-27   115   1.0.3  BUGFIX: set ilam when rbuf read by cpu;
--                           add xdone and rrdy bits to rri xbuf read
-- 2008-01-20   113   1.0.2  fix maint mode logic (proper double buffer now)
-- 2008-01-20   112   1.0.1  use BRESET
-- 2008-01-05   108   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.iblib.all;

-- ----------------------------------------------------------------------------
entity ibdr_dl11 is                     -- ibus dev(rem): DL11-A/B
  generic (
    IB_ADDR : slv16 := slv(to_unsigned(8#177560#,16)));
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- system reset
    BRESET : in slbit;                  -- ibus reset
    RLIM_CEV : in  slv8;                -- clock enable vector
    RB_LAM : out slbit;                 -- remote attention
    IB_MREQ : in ib_mreq_type;          -- ibus request
    IB_SRES : out ib_sres_type;         -- ibus response
    EI_REQ_RX : out slbit;              -- interrupt request, receiver
    EI_REQ_TX : out slbit;              -- interrupt request, transmitter
    EI_ACK_RX : in slbit;               -- interrupt acknowledge, receiver
    EI_ACK_TX : in slbit                -- interrupt acknowledge, transmitter
  );
end ibdr_dl11;

architecture syn of ibdr_dl11 is

  constant ibaddr_rcsr : slv2 := "00";  -- rcsr address offset
  constant ibaddr_rbuf : slv2 := "01";  -- rbuf address offset
  constant ibaddr_xcsr : slv2 := "10";  -- xcsr address offset
  constant ibaddr_xbuf : slv2 := "11";  -- xbuf address offset
  
  subtype  rcsr_ibf_rrlim   is integer range 14 downto 12;
  constant rcsr_ibf_rdone : integer :=  7;
  constant rcsr_ibf_rie :   integer :=  6;
  constant rcsr_ibf_rir :   integer :=  5;
  
  constant rbuf_ibf_rsize0: integer :=  8;
  constant rbuf_ibf_xsize0: integer :=  0;
  subtype  rbuf_ibf_data    is integer range  7 downto 0;
  
  constant xcsr_ibf_xrdy :  integer :=  7;
  constant xcsr_ibf_xie :   integer :=  6;
  constant xcsr_ibf_xir :   integer :=  5;

  constant xbuf_ibf_xval :  integer := 15;
  constant xbuf_ibf_xval8 : integer :=  8;

  type regs_type is record              -- state registers
    ibsel : slbit;                      -- ibus select
    rrlim : slv3;                       -- rcsr: receiver rate limit
    rdone : slbit;                      -- rcsr: receiver done
    rie : slbit;                        -- rcsr: receiver interrupt enable
    rbuf : slv8;                        -- rbuf:
    rval : slbit;                       -- rx rbuf valid
    rintreq : slbit;                    -- rx interrupt request
    xrdy : slbit;                       -- xcsr: transmitter ready
    xie : slbit;                        -- xcsr: transmitter interrupt enable
    xbuf : slv8;                        -- xbuf:
    xintreq : slbit;                    -- tx interrupt request
  end record regs_type;

  constant regs_init : regs_type := (
    '0',                                -- ibsel
    (others=>'0'),                      -- rrlim
    '0','0',                            -- rdone, rie
    (others=>'0'),                      -- rbuf
    '0','0',                            -- rval,rintreq
    '1',                                -- xrdy !! is set !!
    '0',                                -- xie
    (others=>'0'),                      -- xbuf
    '0'                                 -- xintreq
  );

  signal R_REGS : regs_type := regs_init;
  signal N_REGS : regs_type := regs_init;
  
  signal RRLIM_START : slbit := '0';
  signal RRLIM_BUSY  : slbit := '0';

begin
  
  RRLIM : ib_rlim_slv
    port map (
      CLK      => CLK,
      RESET    => RESET,
      RLIM_CEV => RLIM_CEV,
      SEL      => R_REGS.rrlim,
      START    => RRLIM_START,
      STOP     => BRESET,
      DONE     => open,
      BUSY     => RRLIM_BUSY
    );

  proc_regs: process (CLK)
  begin
    if rising_edge(CLK) then
      if BRESET = '1' then
        R_REGS <= regs_init;
        if RESET = '0' then               -- if RESET=0 we do just an ibus reset
          R_REGS.rrlim <= N_REGS.rrlim;     -- keep RLIM flag
        end if;
      else
        R_REGS <= N_REGS;
      end if;
    end if;
  end process proc_regs;

  proc_next : process (R_REGS, IB_MREQ, EI_ACK_RX, EI_ACK_TX, RRLIM_BUSY)
    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;
    variable idout : slv16 := (others=>'0');
    variable ibreq : slbit := '0';
    variable ibrd : slbit := '0';
    variable ibw0 : slbit := '0';
    variable ibw1 : slbit := '0';
    variable ilam : slbit := '0';
    variable irrlimsta : slbit := '0';
  begin

    r := R_REGS;
    n := R_REGS;

    idout := (others=>'0');
    ibreq := IB_MREQ.re or IB_MREQ.we;
    ibrd  := IB_MREQ.re;
    ibw0  := IB_MREQ.we and IB_MREQ.be0;
    ibw1  := IB_MREQ.we and IB_MREQ.be1;
    ilam  := '0';
    irrlimsta := '0';
      
    -- ibus address decoder
    n.ibsel := '0';
    if IB_MREQ.aval='1' and
       IB_MREQ.addr(12 downto 3)=IB_ADDR(12 downto 3) then
      n.ibsel := '1';
    end if;

    -- ibus transactions
    if r.ibsel = '1' then
      case IB_MREQ.addr(2 downto 1) is

        when ibaddr_rcsr =>             -- RCSR -- receive control status ----
          idout(rcsr_ibf_rdone) := r.rdone;
          idout(rcsr_ibf_rie)   := r.rie;
          
          if IB_MREQ.racc = '0' then     -- cpu ---------------------
            if ibw0 = '1' then               -- rcsr write
              n.rie := IB_MREQ.din(rcsr_ibf_rie);
              if IB_MREQ.din(rcsr_ibf_rie) = '1' then
                if r.rdone='1' and r.rie='0' then -- ie set while done=1
                  n.rintreq := '1';               -- request interrupt
                end if;
              else
                n.rintreq := '0';
              end if;
            end if;

          else                          -- rri ---------------------
            idout(rcsr_ibf_rrlim) := r.rrlim;
            idout(rcsr_ibf_rir)   := r.rintreq;
            if ibw1 = '1' then
              n.rrlim := IB_MREQ.din(rcsr_ibf_rrlim);
            end if;
          end if;

        when ibaddr_rbuf =>             -- RBUF -- receive data buffer -------

          if IB_MREQ.racc = '0' then    -- cpu ---------------------
            idout(rbuf_ibf_data) := r.rbuf;
            if ibrd = '1' then             -- rbuf read
              n.rintreq := '0';               -- cancel interrupt
            end if;
            if ibrd='1' and r.rdone='1' then
              n.rval    := '0';           -- clear rbuf valid
              irrlimsta := '1';           -- start rx timer
              ilam := '1';                -- request rb attention
            end if;

          else                          -- rri ---------------------
            idout(rbuf_ibf_rsize0) := r.rval;      -- rbuf occupied when rval=1
            idout(rbuf_ibf_xsize0) := not r.xrdy;  -- xbuf empty    when xrdy=1
            if ibw0 = '1' then
              n.rbuf := IB_MREQ.din(rbuf_ibf_data);
              n.rval := '1';              -- set rbuf valid
            end if;
          end if;

        when ibaddr_xcsr =>             -- XCSR -- transmit control status ---

          idout(xcsr_ibf_xrdy)  := r.xrdy;
          idout(xcsr_ibf_xie)   := r.xie;

          if IB_MREQ.racc = '0' then    -- cpu ---------------------
            if ibw0 = '1' then
              n.xie   := IB_MREQ.din(xcsr_ibf_xie);
              if IB_MREQ.din(xcsr_ibf_xie) = '1' then
                if r.xrdy='1' and r.xie='0' then -- ie set while ready=1
                  n.xintreq := '1';               -- request interrupt
                end if;
              else
                n.xintreq := '0';
              end if;
            end if;

          else                          -- rri ---------------------
            idout(xcsr_ibf_xir)   := r.xintreq;
          end if;
          
        when ibaddr_xbuf =>             -- XBUF -- transmit data buffer ------

          if IB_MREQ.racc = '0' then    -- cpu ---------------------
            if ibw0 = '1' then
              n.xbuf := IB_MREQ.din(n.xbuf'range);
              n.xrdy := '0';
              n.xintreq := '0';
              ilam := '1';
            end if;

          else                          -- rri ---------------------
            idout(r.xbuf'range)   := r.xbuf;
            idout(xbuf_ibf_xval)  := not r.xrdy;
            idout(xbuf_ibf_xval8) := not r.xrdy;
            if ibrd = '1' then
              n.xrdy := '1';
              if r.xie = '1' then
                n.xintreq := '1';
              end if;
            end if;
          end if;

        when others => null;
      end case;

    end if;    

    -- other state changes
  
    if EI_ACK_RX = '1' then
      n.rintreq := '0';
    end if;
    if EI_ACK_TX = '1' then
      n.xintreq := '0';
    end if;

    if (RRLIM_BUSY or (not r.rval)) = '1' then -- busy or no data
      n.rdone   := '0';                          -- clear done
      n.rintreq := '0';                          -- clear pending interrupts
    else                                       -- not busy and data valid
      n.rdone := '1';                            -- set done
      if r.rdone='0' and r.rie='1' then          -- done going 0->1 and ie=1
        n.rintreq := '1';                        -- request rx interrupt
      end if;
    end if;
    
    N_REGS <= n;
    
    RRLIM_START <= irrlimsta;

    IB_SRES.dout <= idout;
    IB_SRES.ack  <= r.ibsel and ibreq;
    IB_SRES.busy <= '0';

    RB_LAM    <= ilam;
    EI_REQ_RX <= r.rintreq;
    EI_REQ_TX <= r.xintreq;
    
  end process proc_next;

    
end syn;
