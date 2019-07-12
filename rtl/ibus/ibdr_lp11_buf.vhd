-- $Id: ibdr_lp11_buf.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    ibdr_lp11_buf - syn
-- Description:    ibus dev(rem): LP11
--
-- Dependencies:   fifo_simple_dram
--                 ib_rlim_slv
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  ise 8.2-14.7; viv 2017.2-2018.3; ghdl 0.35
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2019-05-31  1156   1.0.4  size->fuse rename; re-organize rlim handling
-- 2019-04-24  1138   1.0.3  add csr.ir (intreq monitor)
-- 2019-04-20  1134   1.0.2  remove fifo clear on BRESET
-- 2019-04-14  1131   1.0.1  RLIM_CEV now slv8
-- 2019-03-17  1123   1.0    Initial version
-- 2019-03-10  1121   0.1    First draft (derived from ibdr_lp11)
------------------------------------------------------------------------------
--
-- Notes:
--   - the ERR bit is just a status flag
--   - no hardware interlock (DONE forced 0 when ERR=1), like in simh
--   - also no interrupt when ERR goes 1, like in simh


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.memlib.all;
use work.iblib.all;

-- ----------------------------------------------------------------------------
entity ibdr_lp11_buf is                 -- ibus dev(rem): LP11  (buffered)
                                        -- fixed address: 177514
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
    EI_REQ : out slbit;                 -- interrupt request
    EI_ACK : in slbit                   -- interrupt acknowledge
  );
end ibdr_lp11_buf;

architecture syn of ibdr_lp11_buf is

  constant ibaddr_lp11 : slv16 := slv(to_unsigned(8#177514#,16));

  constant ibaddr_csr : slv1 := "0";   -- csr address offset
  constant ibaddr_buf : slv1 := "1";   -- buf address offset
  
  constant csr_ibf_err :   integer := 15;
  subtype  csr_ibf_rlim    is integer range 14 downto 12;
  subtype  csr_ibf_type    is integer range 10 downto  8;
  constant csr_ibf_done :  integer :=  7;
  constant csr_ibf_ie :    integer :=  6;
  constant csr_ibf_ir :    integer :=  5;
  constant buf_ibf_val :   integer := 15;
  subtype  buf_ibf_fuse    is integer range AWIDTH-1+8 downto 8;
  subtype  buf_ibf_data    is integer range  6 downto 0;

  type regs_type is record              -- state registers
    ibsel : slbit;                      -- ibus select
    err : slbit;                        -- csr: error flag
    rlim : slv3;                        -- csr: rate limit
    done : slbit;                       -- csr: done flag
    ie : slbit;                         -- csr: interrupt enable
    intreq : slbit;                     -- interrupt request
  end record regs_type;

  constant regs_init : regs_type := (
    '0',                                -- ibsel
    '1',                                -- err  !! is set !!
    "000",                              -- rlim
    '1',                                -- done !! is set !!
    '0',                                -- ie
    '0'                                 -- intreq
  );

  signal R_REGS : regs_type := regs_init;
  signal N_REGS : regs_type := regs_init;
  
  signal PBUF_CE : slbit := '0';
  signal PBUF_WE : slbit := '0';
  signal PBUF_DO : slv7  := (others=>'0');
  signal PBUF_RESET : slbit := '0';
  signal PBUF_EMPTY : slbit := '0';
  signal PBUF_FULL  : slbit := '0';
  signal PBUF_FUSE  : slv(AWIDTH-1 downto 0) := (others=>'0');

  signal RLIM_START : slbit := '0';
  signal RLIM_BUSY  : slbit := '0';
  
begin
  
  assert AWIDTH>=4 and AWIDTH<=7 
    report "assert(AWIDTH>=4 and AWIDTH<=7): unsupported AWIDTH"
    severity failure;
  
  PBUF : fifo_simple_dram
    generic map (
      AWIDTH => AWIDTH,
      DWIDTH =>  7)
    port map (
      CLK   => CLK,
      RESET => PBUF_RESET,
      CE    => PBUF_CE,
      WE    => PBUF_WE,
      DI    => IB_MREQ.din(buf_ibf_data),
      DO    => PBUF_DO,
      EMPTY => PBUF_EMPTY,
      FULL  => PBUF_FULL,
      SIZE  => PBUF_FUSE
      );
  
  RLIM : ib_rlim_slv
    port map (
      CLK      => CLK,
      RESET    => RESET,
      RLIM_CEV => RLIM_CEV,
      SEL      => R_REGS.rlim,
      START    => RLIM_START,
      STOP     => BRESET,
      DONE     => open,
      BUSY     => RLIM_BUSY
    );

  proc_regs: process (CLK)
  begin
    if rising_edge(CLK) then
      if BRESET = '1' then              -- BRESET is 1 for system and ibus reset
        R_REGS <= regs_init;
        if RESET = '0' then               -- if RESET=0 we do just an ibus reset
          R_REGS.err  <= N_REGS.err;        -- keep ERR  flag
          R_REGS.rlim <= N_REGS.rlim;       -- keep RLIM flag
        end if;
      else
        R_REGS <= N_REGS;
      end if;
    end if;
  end process proc_regs;

  proc_next : process (R_REGS, IB_MREQ, EI_ACK, RESET, BRESET,
                       PBUF_DO, PBUF_EMPTY, PBUF_FULL, PBUF_FUSE, RLIM_BUSY)
    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;
    variable idout : slv16 := (others=>'0');
    variable ibreq : slbit := '0';
    variable iback : slbit := '0';
    variable ibrd : slbit := '0';
    variable ibw0 : slbit := '0';
    variable ibw1 : slbit := '0';
    variable ilam : slbit := '0';
    variable ipbufce  : slbit := '0';
    variable ipbufwe  : slbit := '0';
    variable irlimsta : slbit := '0';
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
    ipbufce  := '0';
    ipbufwe  := '0';
    irlimsta := '0';
    
    -- ibus address decoder
    n.ibsel := '0';
    if IB_MREQ.aval='1' and
       IB_MREQ.addr(12 downto 2)=ibaddr_lp11(12 downto 2) then
      n.ibsel := '1';
    end if;

    -- ibus transactions
    if r.ibsel = '1' then               -- ibus selected ---------------------
      case IB_MREQ.addr(1 downto 1) is

        when ibaddr_csr =>              -- CSR -- control status -------------
          idout(csr_ibf_err)  := r.err;
          idout(csr_ibf_done) := r.done;
          idout(csr_ibf_ie)   := r.ie;

          if IB_MREQ.racc = '0' then      -- cpu
            if ibw0 = '1' then
              n.ie   := IB_MREQ.din(csr_ibf_ie);
              if IB_MREQ.din(csr_ibf_ie) = '1' then
                if r.done='1' and r.ie='0' then   -- ie set while done=1
                  n.intreq := '1';                -- request interrupt
                end if;
              else
                n.intreq := '0';
              end if;
            end if;

          else                            -- rri
            idout(csr_ibf_rlim) := r.rlim;
            idout(csr_ibf_type) := slv(to_unsigned(AWIDTH,3));
            idout(csr_ibf_ir)   := r.intreq;
            if ibw1 = '1' then
              n.err  := IB_MREQ.din(csr_ibf_err);
              n.rlim := IB_MREQ.din(csr_ibf_rlim);
              if IB_MREQ.din(csr_ibf_err) = '1' then
                n.done   := '1';
                n.intreq := '0';                    -- clear irupt (like simh!)
              end if;
            end if;
          end if;

        when ibaddr_buf =>              -- BUF -- data buffer ----------------

          if IB_MREQ.racc = '0' then      -- cpu
            if ibw0 = '1' then
              if r.done = '1' then          -- ignore buf write when done=0
                n.done   := '0';              -- clear done
                n.intreq := '0';              -- clear interrupt
                if r.err = '0' then           -- if online (handle via rbus)
                  if PBUF_FULL = '0' then       -- fifo not full
                    ipbufce  := '1';              -- write to fifo
                    ipbufwe  := '1';
                    if PBUF_EMPTY = '1' then      -- first write to empty fifo
                      ilam     := '1';              -- request attention
                    end if;
                  end if;  -- PBUF_FULL = '0'
                else                          -- if offline (discard locally)
                  null;
                end if;  -- r.err = '0'
              end if;  -- r.done = '1'
            end if;  -- ibw0 = '1'

          else                            -- rri
            idout(buf_ibf_val)  := not PBUF_EMPTY;
            idout(buf_ibf_fuse) := PBUF_FUSE;
            idout(buf_ibf_data) := PBUF_DO;
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
      -- handle done, timer and interrupt
      if PBUF_FULL='0' and RLIM_BUSY='0' then -- not full and not busy ?
        if r.done = '0' then                    -- done not set ?
          n.done   := '1';                      -- set done
          irlimsta := '1';                      -- start timer
          if r.err='0' and r.ie='1' then        -- err=0 and irupt enabled ?
            n.intreq := '1';                      -- request interrupt
          end if;
        end if;
      end if;    
    end if; -- else r.ibsel='1'
    
    -- other state changes
    if EI_ACK = '1' then
      n.intreq := '0';
    end if;
    
    N_REGS <= n;

    PBUF_RESET <= RESET or r.err;
    PBUF_CE    <= ipbufce;
    PBUF_WE    <= ipbufwe;
    RLIM_START <= irlimsta;

    IB_SRES.dout <= idout;
    IB_SRES.ack  <= iback;
    IB_SRES.busy <= '0';

    RB_LAM <= ilam;
    EI_REQ <= r.intreq;
    
  end process proc_next;

    
end syn;
