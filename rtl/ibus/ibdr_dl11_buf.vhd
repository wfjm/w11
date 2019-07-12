-- $Id: ibdr_dl11_buf.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    ibdr_dl11_buf - syn
-- Description:    ibus dev(rem): DL11-A/B
--
-- Dependencies:   fifo_simple_dram
--                 ib_rlim_slv
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  ise 8.2-14.7; viv 2017.2; ghdl 0.18-0.35
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2019-05-31  1156   1.0.1  size->fuse rename; re-organize rlim handling
-- 2019-04-26  1139   1.0    Initial version (derived from ibdr_{dl11,pc11_buf})
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.memlib.all;
use work.iblib.all;

-- ----------------------------------------------------------------------------
entity ibdr_dl11_buf is                 -- ibus dev(rem): DL11-A/B
  generic (
    IB_ADDR : slv16 := slv(to_unsigned(8#177560#,16));
    AWIDTH : natural :=  5);            -- fifo address width
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
end ibdr_dl11_buf;

architecture syn of ibdr_dl11_buf is

  constant ibaddr_rcsr : slv2 := "00";  -- rcsr address offset
  constant ibaddr_rbuf : slv2 := "01";  -- rbuf address offset
  constant ibaddr_xcsr : slv2 := "10";  -- xcsr address offset
  constant ibaddr_xbuf : slv2 := "11";  -- xbuf address offset
  
  subtype  rcsr_ibf_rrlim   is integer range 14 downto 12;
  subtype  rcsr_ibf_type    is integer range 10 downto  8;
  constant rcsr_ibf_rdone : integer :=  7;
  constant rcsr_ibf_rie :   integer :=  6;
  constant rcsr_ibf_rir :   integer :=  5;
  constant rcsr_ibf_rlb :   integer :=  4;
  constant rcsr_ibf_fclr :  integer :=  1;
  
  subtype  rbuf_ibf_rfuse   is integer range AWIDTH-1+8 downto 8;
  subtype  rbuf_ibf_xfuse   is integer range AWIDTH-1   downto 0;
  subtype  rbuf_ibf_data    is integer range  7 downto 0;
  
  subtype  xcsr_ibf_xrlim   is integer range 14 downto 12;
  constant xcsr_ibf_xrdy :  integer :=  7;
  constant xcsr_ibf_xie :   integer :=  6;
  constant xcsr_ibf_xir :   integer :=  5;
  constant xcsr_ibf_rlb :   integer :=  4;
  constant xcsr_ibf_fclr :  integer :=  1;

  constant xbuf_ibf_xval :  integer := 15;
  subtype  xbuf_ibf_fuse    is integer range AWIDTH-1+8 downto 8;
  subtype  xbuf_ibf_data    is integer range  7 downto 0;

  type regs_type is record              -- state registers
    ibsel : slbit;                      -- ibus select
    rrlim : slv3;                       -- rcsr: receiver rate limit
    rdone : slbit;                      -- rcsr: receiver done
    rie : slbit;                        -- rcsr: receiver interrupt enable
    rintreq : slbit;                    -- rx interrupt request
    xrlim : slv3;                       -- xcsr: transmitter rate limit
    xrdy : slbit;                       -- xcsr: transmitter ready
    xie : slbit;                        -- xcsr: transmitter interrupt enable
    xintreq : slbit;                    -- tx interrupt request
  end record regs_type;

  constant regs_init : regs_type := (
    '0',                                -- ibsel
    "000",                              -- rrlim
    '0','0','0',                        -- rdone,rie,rintreq
    "000",                              -- xrlim
    '1',                                -- xrdy !! is set !!
    '0',                                -- xie
    '0'                                 -- xintreq
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
  
  signal XBUF_CE : slbit := '0';
  signal XBUF_WE : slbit := '0';
  signal XBUF_DO : slv8  := (others=>'0');
  signal XBUF_RESET : slbit := '0';
  signal XBUF_EMPTY : slbit := '0';
  signal XBUF_FULL  : slbit := '0';
  signal XBUF_FUSE  : slv(AWIDTH-1 downto 0) := (others=>'0');
  
  signal RRLIM_START : slbit := '0';
  signal RRLIM_BUSY  : slbit := '0';
  signal XRLIM_START : slbit := '0';
  signal XRLIM_BUSY  : slbit := '0';

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
  
  XBUF : fifo_simple_dram
    generic map (
      AWIDTH => AWIDTH,
      DWIDTH =>  8)
    port map (
      CLK   => CLK,
      RESET => XBUF_RESET,
      CE    => XBUF_CE,
      WE    => XBUF_WE,
      DI    => IB_MREQ.din(xbuf_ibf_data),
      DO    => XBUF_DO,
      EMPTY => XBUF_EMPTY,
      FULL  => XBUF_FULL,
      SIZE  => XBUF_FUSE
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

  XRLIM : ib_rlim_slv
    port map (
      CLK      => CLK,
      RESET    => RESET,
      RLIM_CEV => RLIM_CEV,
      SEL      => R_REGS.xrlim,
      START    => XRLIM_START,
      STOP     => BRESET,
      DONE     => open,
      BUSY     => XRLIM_BUSY
    );

  proc_regs: process (CLK)
  begin
    if rising_edge(CLK) then
      if BRESET = '1' then
        R_REGS <= regs_init;
        if RESET = '0' then               -- if RESET=0 we do just an ibus reset
          R_REGS.rrlim <= N_REGS.rrlim;     -- keep RRLIM field
          R_REGS.xrlim <= N_REGS.xrlim;     -- keep XRLIM field
        end if;
      else
        R_REGS <= N_REGS;
      end if;
    end if;
  end process proc_regs;

  proc_next : process (R_REGS, IB_MREQ, EI_ACK_RX, EI_ACK_TX, RESET,
                       RBUF_DO, RBUF_EMPTY, RBUF_FULL, RBUF_FUSE, RRLIM_BUSY,
                       XBUF_DO, XBUF_EMPTY, XBUF_FULL, XBUF_FUSE, XRLIM_BUSY)
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
    variable ixbufce   : slbit := '0';
    variable ixbufwe   : slbit := '0';
    variable ixbufrst  : slbit := '0';
    variable ixrlimsta : slbit := '0';
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
    irbufrst  := RESET;
    irrlimsta := '0';
    ixbufce   := '0';
    ixbufwe   := '0';
    ixbufrst  := RESET;
    ixrlimsta := '0';
       
    -- ibus address decoder
    n.ibsel := '0';
    if IB_MREQ.aval='1' and
       IB_MREQ.addr(12 downto 3)=IB_ADDR(12 downto 3) then
      n.ibsel := '1';
    end if;

    -- ibus transactions
    if r.ibsel = '1' then               -- ibus selected ---------------------
      case IB_MREQ.addr(2 downto 1) is

        when ibaddr_rcsr =>             -- RCSR -- receive control status ----

          idout(rcsr_ibf_rdone) := r.rdone;
          idout(rcsr_ibf_rie)   := r.rie;

          if IB_MREQ.racc = '0' then     -- cpu ---------------------
            if ibw0 = '1' then             -- rcsr write
              n.rie := IB_MREQ.din(rcsr_ibf_rie);
              if IB_MREQ.din(rcsr_ibf_rie) = '1' then-- set IE to 1
                if r.rdone='1' and r.rie='0' then     -- ie 0->1 while done=1
                  n.rintreq := '1';                     -- request interrupt
                end if;
              else                                   -- set IE to 0
                n.rintreq := '0';                      -- cancel interrupt
              end if;
            end if;

          else                          -- rri ---------------------
            idout(rcsr_ibf_rrlim) := r.rrlim;
            idout(rcsr_ibf_type)  := slv(to_unsigned(AWIDTH,3));
            idout(rcsr_ibf_rir)   := r.rintreq;
            idout(rcsr_ibf_rlb)   := RRLIM_BUSY;

            if ibw1 = '1' then
              n.rrlim := IB_MREQ.din(rcsr_ibf_rrlim);
            end if;
            if ibw0 = '1' then
              if IB_MREQ.din(rcsr_ibf_fclr) = '1' then -- 1 written to FCLR
                irbufrst := '1';                         -- then reset fifo
              end if;
            end if;
          end if;

        when ibaddr_rbuf =>             -- RBUF -- receive data buffer -------

          if IB_MREQ.racc = '0' then    -- cpu ---------------------
            idout(rbuf_ibf_data) := RBUF_DO;
            if ibrd = '1' then                -- rbuf read
              n.rdone   := '0';                 -- clear done
              n.rintreq := '0';                 -- cancel interrupt
              if r.rdone='1' then               -- data available ?
                irbufce := '1';                    -- read next from fifo
                irbufwe := '0';
                if RBUF_FUSE = c_fuse1 then        -- last value (fuse=1) ?
                  ilam := '1';                       -- rri lam
                end if;
              end if;
            end if;

          else                          -- rri ---------------------
            idout(rbuf_ibf_rfuse) := RBUF_FUSE;
            idout(rbuf_ibf_xfuse) := XBUF_FUSE;
            if ibw0 = '1' then
              if RBUF_FULL = '0' then       -- fifo not full
                irbufce  := '1';              -- write to fifo
                irbufwe  := '1';
              else                          -- write to full fifo
                iback := '0';                 -- signal nak
              end if;
            end if;
          end if;

        when ibaddr_xcsr =>             -- XCSR -- transmit control status ---

          idout(xcsr_ibf_xrdy)  := r.xrdy;
          idout(xcsr_ibf_xie)   := r.xie;

          if IB_MREQ.racc = '0' then    -- cpu ---------------------
            if ibw0 = '1' then
              n.xie   := IB_MREQ.din(xcsr_ibf_xie);
              if IB_MREQ.din(xcsr_ibf_xie) = '1' then-- set IE to 1
                if r.xrdy='1' and r.xie='0' then     -- ie 0->1 while ready=1
                  n.xintreq := '1';                    -- request interrupt
                end if;
              else                                   -- set IE to 0
                n.xintreq := '0';                      --  cancel interrupts
              end if;
            end if;

          else                          -- rri ---------------------
            idout(xcsr_ibf_xrlim) := r.xrlim;
            idout(xcsr_ibf_xir)   := r.xintreq;
            idout(xcsr_ibf_rlb)   := XRLIM_BUSY;

            if ibw1 = '1' then
              n.xrlim := IB_MREQ.din(xcsr_ibf_xrlim);  -- set XRLIM field
            end if;
            if ibw0 = '1' then
              if IB_MREQ.din(xcsr_ibf_fclr) = '1' then -- 1 written to FCLR
                ixbufrst := '1';                         -- then reset fifo
              end if;
            end if;
         end if;
          
        when ibaddr_xbuf =>             -- XBUF -- transmit data buffer ------

          if IB_MREQ.racc = '0' then    -- cpu ---------------------
            if ibw0 = '1' then
              if r.xrdy = '1' then        -- ignore buf write when rdy=0
                n.xrdy    := '0';           -- clear ready
                n.xintreq := '0';           -- cancel interrupt
                if XBUF_FULL = '0' then     -- fifo not full
                  ixbufce  := '1';            -- write to fifo
                  ixbufwe  := '1';
                  if XBUF_EMPTY = '1' then    -- first write to empty fifo
                    ilam     := '1';            -- request attention
                  end if;
                end if;
              end if;
            end if;

          else                          -- rri ---------------------
            idout(xbuf_ibf_xval)  := not XBUF_EMPTY;
            idout(xbuf_ibf_fuse)  := XBUF_FUSE;
            idout(xbuf_ibf_data)  := XBUF_DO;
            if ibrd = '1' then
              if XBUF_EMPTY = '0' then      -- fifo not empty
                ixbufce := '1';               -- read from fifo
                ixbufwe := '0';
              else                          -- read from empty fifo
                iback := '0';                 -- signal nak
              end if;
            end if;
          end if;

        when others => null;
      end case;
      
    else                                -- ibus not selected -----------------
      -- handle rx done, timer and interrupt
      if RBUF_EMPTY='0' and RRLIM_BUSY='0' then -- not empty and not busy ?
        if r.rdone = '0' then                     -- done not set ?
          n.rdone   := '1';                         -- set done
          irrlimsta := '1';                         -- start timer
          if r.rie = '1' then                       -- irupts enabled ?
            n.rintreq := '1';                         -- request rx interrupt
          end if;
        end if;
      end if;

      -- handle tx ready, timer and interrupt
      if XBUF_FULL='0' and XRLIM_BUSY='0' then -- not full and not busy ?
        if r.xrdy = '0' then                     -- ready not set ?
          n.xrdy    := '1';                        -- set ready
          ixrlimsta := '1';                        -- start timer
          if r.xie = '1' then                      -- irupts enabled ?
            n.xintreq := '1';                        -- request tx interrupt
          end if;
        end if;
      end if;
    end if;     -- else r.ibsel='1'

    -- other state changes
  
    if EI_ACK_RX = '1' then
      n.rintreq := '0';
    end if;
    if EI_ACK_TX = '1' then
      n.xintreq := '0';
    end if;

    N_REGS <= n;
    
    RBUF_RESET  <= irbufrst;
    RBUF_CE     <= irbufce;
    RBUF_WE     <= irbufwe;
    RRLIM_START <= irrlimsta;

    XBUF_RESET  <= ixbufrst;
    XBUF_CE     <= ixbufce;
    XBUF_WE     <= ixbufwe;
    XRLIM_START <= ixrlimsta;

    IB_SRES.dout <= idout;
    IB_SRES.ack  <= iback;
    IB_SRES.busy <= '0';

    RB_LAM    <= ilam;
    EI_REQ_RX <= r.rintreq;
    EI_REQ_TX <= r.xintreq;
    
  end process proc_next;

    
end syn;
