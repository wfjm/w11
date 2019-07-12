-- $Id: ibdr_pc11_buf.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    ibdr_pc11_buf - syn
-- Description:    ibus dev(rem): PC11
--
-- Dependencies:   fifo_simple_dram
--                 ib_rlim_slv
-- Test bench:     xxdp: zpcae0
-- Target Devices: generic
-- Tool versions:  ise 8.2-14.7; 2017.2; ghdl 0.35
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2019-05-31  1156   1.0.1  size->fuse rename; re-organize rlim handling
-- 2019-04-24  1137   1.0    Initial version
-- 2019-04-07  1129   0.1    First draft (derived from ibdr_pc11)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.memlib.all;
use work.iblib.all;

-- ----------------------------------------------------------------------------
entity ibdr_pc11_buf is                 -- ibus dev(rem): PC11
                                        -- fixed address: 177550
  generic (
    AWIDTH : natural :=  5);            -- fifo address width
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- system reset
    BRESET : in slbit;                  -- ibus reset
    RLIM_CEV : in  slv8;                -- clock enable vector
    RB_LAM : out slbit;                 -- remote attention
    IB_MREQ : in ib_mreq_type;          -- ibus request
    IB_SRES : out ib_sres_type;         -- ibus response
    EI_REQ_PTR : out slbit;             -- interrupt request, reader
    EI_REQ_PTP : out slbit;             -- interrupt request, punch
    EI_ACK_PTR : in slbit;              -- interrupt acknowledge, reader
    EI_ACK_PTP : in slbit               -- interrupt acknowledge, punch
  );
end ibdr_pc11_buf;

architecture syn of ibdr_pc11_buf is

  constant ibaddr_pc11 : slv16 := slv(to_unsigned(8#177550#,16));

  constant ibaddr_rcsr : slv2 := "00";  -- rcsr address offset
  constant ibaddr_rbuf : slv2 := "01";  -- rbuf address offset
  constant ibaddr_pcsr : slv2 := "10";  -- pcsr address offset
  constant ibaddr_pbuf : slv2 := "11";  -- pbuf address offset
  
  constant rcsr_ibf_rerr :  integer := 15;
  subtype  rcsr_ibf_rlim    is integer range 14 downto 12;
  constant rcsr_ibf_rbusy : integer := 11;
  subtype  rcsr_ibf_type    is integer range 10 downto  8;
  constant rcsr_ibf_rdone : integer :=  7;
  constant rcsr_ibf_rie :   integer :=  6;
  constant rcsr_ibf_rir  :  integer :=  5;
  constant rcsr_ibf_rlb :   integer :=  4;
  constant rcsr_ibf_ique :  integer :=  3;
  constant rcsr_ibf_iack :  integer :=  2;
  constant rcsr_ibf_fclr :  integer :=  1;
  constant rcsr_ibf_renb :  integer :=  0;

  constant rbuf_ibf_rbusy : integer := 15;
  subtype  rbuf_ibf_rfuse   is integer range AWIDTH-1+8 downto 8;
  subtype  rbuf_ibf_pfuse   is integer range AWIDTH-1   downto 0;
  subtype  rbuf_ibf_data    is integer range  7 downto 0;

  constant pcsr_ibf_perr :  integer := 15;
  subtype  pcsr_ibf_rlim    is integer range 14 downto 12;
  constant pcsr_ibf_prdy :  integer :=  7;
  constant pcsr_ibf_pie :   integer :=  6;
  constant pcsr_ibf_pir :   integer :=  5;
  constant pcsr_ibf_rlb :   integer :=  4;

  constant pbuf_ibf_pval :  integer := 15;
  subtype  pbuf_ibf_fuse    is integer range AWIDTH-1+8 downto 8;
  subtype  pbuf_ibf_data    is integer range  7 downto 0;

  type regs_type is record              -- state registers
    ibsel : slbit;                      -- ibus select
    rerr : slbit;                       -- rcsr: reader error
    rrlim : slv3;                       -- rcsr: reader rlim
    rbusy : slbit;                      -- rcsr: reader busy
    rdone : slbit;                      -- rcsr: reader done
    rie : slbit;                        -- rcsr: reader interrupt enable
    rintreq : slbit;                    -- ptr interrupt request
    rique : slbit;                      -- ptr interrupt queued (req set)
    riack : slbit;                      -- ptr interrupt acknowledged
    perr : slbit;                       -- pcsr: punch error
    prlim : slv3;                       -- pcsr: punch rlim
    prdy : slbit;                       -- pcsr: punch ready
    pie : slbit;                        -- pcsr: punch interrupt enable
    pintreq : slbit;                    -- ptp interrupt request
  end record regs_type;

  constant regs_init : regs_type := (
    '0',                                -- ibsel
    '1',                                -- rerr (init=1!)
    "000",                              -- rrlim
    '0','0','0',                        -- rbusy,rdone,rie
    '0','0','0',                        -- rintreq,rique,riack
    '1',                                -- perr (init=1!)
    "000",                              -- prlim
    '1',                                -- prdy (init=1!)
    '0',                                -- pie
    '0'                                 -- pintreq
  );

  constant c_fuse1 : slv(AWIDTH-1 downto 0) := slv(to_unsigned(1,AWIDTH));

  signal R_REGS : regs_type := regs_init;
  signal N_REGS : regs_type := regs_init;
  
  signal RBUF_CE : slbit := '0';
  signal RBUF_WE : slbit := '0';
  signal RBUF_DO : slv8  := (others=>'0');
  signal RBUF_RESET : slbit := '0';
  signal RBUF_EMPTY : slbit := '0';
  signal RBUF_FULL  : slbit := '0';
  signal RBUF_FUSE  : slv(AWIDTH-1 downto 0) := (others=>'0');
  
  signal PBUF_CE : slbit := '0';
  signal PBUF_WE : slbit := '0';
  signal PBUF_DO : slv8  := (others=>'0');
  signal PBUF_RESET : slbit := '0';
  signal PBUF_EMPTY : slbit := '0';
  signal PBUF_FULL  : slbit := '0';
  signal PBUF_FUSE  : slv(AWIDTH-1 downto 0) := (others=>'0');

  signal RRLIM_START : slbit := '0';
  signal RRLIM_BUSY  : slbit := '0';
  signal PRLIM_START : slbit := '0';
  signal PRLIM_BUSY  : slbit := '0';

begin
  
  assert AWIDTH>=4 and AWIDTH<=7 
    report "assert(AWIDTH>=4 and AWIDTH<=7): unsupported AWIDTH"
    severity failure;
  
  RBUF : fifo_simple_dram
    generic map (
      AWIDTH => AWIDTH,
      DWIDTH =>  8)
    port map (
      CLK   => CLK,
      RESET => RBUF_RESET,
      CE    => RBUF_CE,
      WE    => RBUF_WE,
      DI    => IB_MREQ.din(rbuf_ibf_data),
      DO    => RBUF_DO,
      EMPTY => RBUF_EMPTY,
      FULL  => RBUF_FULL,
      SIZE  => RBUF_FUSE
    );
  
  PBUF : fifo_simple_dram
    generic map (
      AWIDTH => AWIDTH,
      DWIDTH =>  8)
    port map (
      CLK   => CLK,
      RESET => PBUF_RESET,
      CE    => PBUF_CE,
      WE    => PBUF_WE,
      DI    => IB_MREQ.din(pbuf_ibf_data),
      DO    => PBUF_DO,
      EMPTY => PBUF_EMPTY,
      FULL  => PBUF_FULL,
      SIZE  => PBUF_FUSE
    );
  
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
  
  PRLIM : ib_rlim_slv
    port map (
      CLK      => CLK,
      RESET    => RESET,
      RLIM_CEV => RLIM_CEV,
      SEL      => R_REGS.prlim,
      START    => PRLIM_START,
      STOP     => BRESET,
      DONE     => open,
      BUSY     => PRLIM_BUSY
    );

  proc_regs: process (CLK)
  begin
    if rising_edge(CLK) then
      if BRESET = '1' then              -- BRESET is 1 for system and ibus reset
        R_REGS <= regs_init;            --
        if RESET = '0' then               -- if RESET=0 we do just an ibus reset
          R_REGS.rerr  <= N_REGS.rerr;      -- keep RERR  flag
          R_REGS.rrlim <= N_REGS.rrlim;     -- keep RRLIM field
          R_REGS.perr  <= N_REGS.perr;      -- keep PERR  flag
          R_REGS.prlim <= N_REGS.prlim;     -- keep PRLIM field
        end if;
      else
        R_REGS <= N_REGS;
      end if;
    end if;
  end process proc_regs;

  proc_next : process (R_REGS, IB_MREQ, EI_ACK_PTR, EI_ACK_PTP, RESET,
                       RBUF_DO, RBUF_EMPTY, RBUF_FULL, RBUF_FUSE, RRLIM_BUSY,
                       PBUF_DO, PBUF_EMPTY, PBUF_FULL, PBUF_FUSE, PRLIM_BUSY)
    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;
    variable idout : slv16 := (others=>'0');
    variable ibreq : slbit := '0';
    variable iback : slbit := '0';
    variable ibrd : slbit := '0';
    variable ibw0 : slbit := '0';
    variable ibw1 : slbit := '0';
    variable ilam : slbit := '0';
    variable irbufce   : slbit := '0';
    variable irbufwe   : slbit := '0';
    variable irbufrst  : slbit := '0';
    variable irrlimsta : slbit := '0';
    variable ipbufce   : slbit := '0';
    variable ipbufwe   : slbit := '0';
    variable iprlimsta : slbit := '0';
  begin

    r := R_REGS;
    n := R_REGS;

    idout := (others=>'0');
    ibreq := IB_MREQ.re or IB_MREQ.we;
    iback := r.ibsel and ibreq;
    ibrd  := IB_MREQ.re;
    ibw0  := IB_MREQ.we and IB_MREQ.be0;
    ibw1  := IB_MREQ.we and IB_MREQ.be1;
    ilam  := '0';
    irbufce   := '0';
    irbufwe   := '0';
    irbufrst  := RESET or r.rerr;
    irrlimsta := '0';
    ipbufce   := '0';
    ipbufwe   := '0';
    iprlimsta := '0';
     
    -- ibus address decoder
    n.ibsel := '0';
    if IB_MREQ.aval='1' and
       IB_MREQ.addr(12 downto 3)=ibaddr_pc11(12 downto 3) then
      n.ibsel := '1';
    end if;

    -- ibus transactions
    if r.ibsel = '1' then               -- ibus selected ---------------------
      case IB_MREQ.addr(2 downto 1) is

        when ibaddr_rcsr =>             -- RCSR -- reader control status -----

          idout(rcsr_ibf_rerr)  := r.rerr;
          idout(rcsr_ibf_rbusy) := r.rbusy;
          idout(rcsr_ibf_rdone) := r.rdone;
          idout(rcsr_ibf_rie)   := r.rie;

          if IB_MREQ.racc = '0' then    -- cpu ---------------------
            if ibw0 = '1' then
              n.rie := IB_MREQ.din(rcsr_ibf_rie);
              if IB_MREQ.din(rcsr_ibf_rie) = '1' then-- set IE to 1
                if r.rie = '0' and                     -- IE 0->1 transition
                   IB_MREQ.din(rcsr_ibf_renb)='0' and  -- when RENB not set
                   (r.rerr='1' or r.rdone='1') then    -- but err or done set
                  n.rintreq := '1';                      -- request interrupt
                  n.rique   := '1';                      -- and set que flag
                end if;
              else                                   -- set IE to 0
                n.rintreq := '0';                      -- cancel interrupts
              end if;
              if IB_MREQ.din(rcsr_ibf_renb) = '1' then -- set RENB
                if r.rerr = '0' then                   -- if not in error state
                  n.rbusy   := '1';                      -- set busy
                  n.rdone   := '0';                      -- clear done
                  n.rintreq := '0';                      -- cancel interrupt
                  n.rique   := '0';                      --   and que flag
                  n.riack   := '0';                      --   and ack flag
                else                                   -- if in error state
                  if r.rie = '1' then                    -- if interrupts on
                    n.rintreq := '1';                      -- request interrupt
                    n.rique   := '1';                      -- and set que flag
                  end if;
                end if;
              end if;
            end if;

          else                          -- rri ---------------------
            idout(rcsr_ibf_rlim)  := r.rrlim;
            idout(rcsr_ibf_type)  := slv(to_unsigned(AWIDTH,3));
            idout(rcsr_ibf_rir)   := r.rintreq;
            idout(rcsr_ibf_rlb)   := RRLIM_BUSY;
            idout(rcsr_ibf_ique)  := r.rique;
            idout(rcsr_ibf_iack)  := r.riack; 

            if ibw1 = '1' then
              n.rerr  := IB_MREQ.din(rcsr_ibf_rerr); -- set ERR bit
              n.rrlim := IB_MREQ.din(rcsr_ibf_rlim); -- set RLIM field
              if IB_MREQ.din(rcsr_ibf_rerr)='1'      -- if 0->1 transition
                 and r.rerr='0' and r.rie = '1' then  -- and interrupts on
                  n.rintreq := '1';                      -- request interrupt
                  n.rique   := '1';                      -- and set que flag
              end if;
            end if;
            if ibw0 = '1' then
              if IB_MREQ.din(rcsr_ibf_fclr) = '1' then -- 1 written to FCLR
                irbufrst := '1';                         -- then reset fifo
              end if;
            end if;
          end if;

        when ibaddr_rbuf =>             -- RBUF -- reader data buffer --------

          if IB_MREQ.racc = '0' then    -- cpu ---------------------
            -- the PC11 clears the reader data buffer when read (unusual!!)
            -- this is emulated by returning fifo data only when DONE=1
            if r.rdone = '1' then
              idout(rbuf_ibf_data) := RBUF_DO;
            end if;
            if ibreq = '1' then           -- !! PC11 is unusual !!
              n.rdone   := '0';           -- *any* read or write will clear done
              n.rintreq := '0';           -- also interrupt is canceled
              if r.rdone = '1'  then      -- data available
                irbufce := '1';             -- read next value from fifo
                irbufwe := '0';
                if RBUF_FUSE = c_fuse1 then -- last value (fuse=1)
                  ilam := '1';                -- rri lam
                end if;
              end if;
            end if;

          else                          -- rri ---------------------
            idout(rbuf_ibf_rbusy) := r.rbusy;
            idout(rbuf_ibf_rfuse) := RBUF_FUSE;
            idout(rbuf_ibf_pfuse) := PBUF_FUSE;
            if ibw0 = '1' then
              if RBUF_FULL = '0' then       -- fifo not full
                irbufce  := '1';              -- write to fifo
                irbufwe  := '1';
              else                          -- write to full fifo
                iback := '0';                 -- signal nak
              end if;
            end if;
          end if;

        when ibaddr_pcsr =>             -- PCSR -- punch control status ------

          idout(pcsr_ibf_perr)  := r.perr;
          idout(pcsr_ibf_prdy)  := r.prdy;
          idout(pcsr_ibf_pie)   := r.pie;

          if IB_MREQ.racc = '0' then    -- cpu ---------------------
            if ibw0 = '1' then
              n.pie   := IB_MREQ.din(pcsr_ibf_pie);
              if IB_MREQ.din(pcsr_ibf_pie) = '1' then-- set IE to 1
                if r.pie='0' and                       -- IE 0->1 transition
                  (r.perr='1' or r.prdy='1') then      -- but err or done set
                  n.pintreq := '1';               -- request interrupt
                end if;
              else                                   -- set IE to 0
                n.pintreq := '0';                      -- cancel interrupts
              end if;
            end if;

          else                          -- rri ---------------------
            idout(pcsr_ibf_rlim) := r.prlim;
            idout(pcsr_ibf_pir)  := r.pintreq;
            idout(pcsr_ibf_rlb)  := PRLIM_BUSY;
            
            if ibw1 = '1' then
              n.perr  := IB_MREQ.din(pcsr_ibf_perr);  -- set ERR bit
              n.prlim := IB_MREQ.din(pcsr_ibf_rlim);  -- set RLIM field
              if IB_MREQ.din(pcsr_ibf_perr)='1'      -- if 0->1 transition
                 and r.perr='0' then
                n.prdy := '1';                         -- set ready
                if r.pie = '1' then                    -- if interrupts on
                  n.pintreq := '1';                      -- request interrupt
                end if;
              end if;
            end if;
          end if;

        when ibaddr_pbuf =>             -- PBUF -- punch data buffer ---------

          if IB_MREQ.racc = '0' then    -- cpu ---------------------
            if ibw0 = '1' then
              if r.perr = '0' then        -- if not in error state
               if r.prdy = '1' then        -- ignore buf write when rdy=0
                  n.prdy    := '0';           -- clear ready
                  n.pintreq := '0';           -- cancel interrupt
                  if PBUF_FULL = '0' then     -- fifo not full
                    ipbufce  := '1';            -- write to fifo
                    ipbufwe  := '1';
                    if PBUF_EMPTY = '1' then    -- first write to empty fifo
                      ilam     := '1';            -- request attention
                    end if;
                  end if;
                end if;
              else                        -- if in error state
                if r.pie = '1' then         -- if interrupts on
                  n.pintreq := '1';           -- request interrupt
                end if;
              end if;
            end if;

          else                          -- rri ---------------------
            idout(pbuf_ibf_pval)  := not PBUF_EMPTY;
            idout(pbuf_ibf_fuse)  := PBUF_FUSE;
            idout(pbuf_ibf_data)  := PBUF_DO;
            if ibrd = '1' then
              if PBUF_EMPTY = '0' then      -- fifo not empty
                ipbufce := '1';               -- read from fifo
                ipbufwe := '0';
              else                          -- read from empty fifo
                iback := '0';                 -- signal nak
              end if;
            end if;
          end if;

        when others => null;
      end case;
      
    else                                -- ibus not selected -----------------
      -- handle pr done, timer and interrupt
      if RBUF_EMPTY='0' and RRLIM_BUSY='0' then -- not empty and not busy ?
        if r.rbusy = '1' then                   -- reader enabled ?
          n.rbusy   := '0';                       -- clear busy
          n.rdone   := '1';                       -- set done
          irrlimsta := '1';                       -- start timer
          if r.rdone='0' and                      -- done going 0->1
             r.rerr='0' and r.rie='1' then        -- and err=0 and ie=1 
            n.rintreq := '1';                       -- request interrupt
            n.rique   := '1';                       -- and set que flag
          end if;
        end if;
      end if;
 
      -- handle pp ready, timer and interrupt
      if PBUF_FULL='0' and PRLIM_BUSY='0' then -- not full and not busy ?
        if r.prdy = '0' then                     -- ready not set ? 
          n.prdy    := '1';                        -- set ready
          iprlimsta := '1';                        -- start timer
          if r.perr='0' and r.pie='1' then         -- err=0 and irupt enabled 
            n.pintreq := '1';                        -- request interrupt
          end if;
        end if;
      end if;
    end if; -- else r.ibsel='1'

    -- other state changes
    if EI_ACK_PTR = '1' then
      n.rintreq := '0';
      n.riack   := '1';
    end if;
    if EI_ACK_PTP = '1' then
      n.pintreq := '0';
    end if;
    
    N_REGS <= n;

    RBUF_RESET  <= irbufrst;
    RBUF_CE     <= irbufce;
    RBUF_WE     <= irbufwe;
    RRLIM_START <= irrlimsta;
    
    PBUF_RESET  <= RESET or r.perr;
    PBUF_CE     <= ipbufce;
    PBUF_WE     <= ipbufwe;
    PRLIM_START <= iprlimsta;

    IB_SRES.dout <= idout;
    IB_SRES.ack  <= iback;
    IB_SRES.busy <= '0';

    RB_LAM     <= ilam;
    EI_REQ_PTR <= r.rintreq;
    EI_REQ_PTP <= r.pintreq;
    
  end process proc_next;

    
end syn;
