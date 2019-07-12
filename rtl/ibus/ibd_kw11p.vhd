-- $Id: ibd_kw11p.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2018-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    ibd_kw11p - syn
-- Description:    ibus dev(loc): KW11-P (programmable line clock)
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  ise 14.7; viv 2017.2-2018.2; ghdl 0.34
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2018-09-09  1043 14.7  131013 xc6slx16-2    61  110    0   42 s  6.2
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2019-04-24  1138   1.1    add csr.ir; add rem controllable options for
--                           RATE=11: sysclk, 1 Mhz, extevt, none
-- 2018-09-09  1043   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.iblib.all;

-- ----------------------------------------------------------------------------
entity ibd_kw11p is                     -- ibus dev(loc): KW11-P (line clock)
                                        -- fixed address: 172540
  port (
    CLK : in slbit;                     -- clock
    CE_USEC : in slbit;                 -- usec pulse
    CE_MSEC : in slbit;                 -- msec pulse
    RESET : in slbit;                   -- system reset
    BRESET : in slbit;                  -- ibus reset
    EXTEVT : in slbit;                  -- external event for RATE="11"
    CPUSUSP : in slbit;                 -- cpu suspended
    IB_MREQ : in ib_mreq_type;          -- ibus request
    IB_SRES : out ib_sres_type;         -- ibus response
    EI_REQ : out slbit;                 -- interrupt request
    EI_ACK : in slbit                   -- interrupt acknowledge
  );
end ibd_kw11p;

architecture syn of ibd_kw11p is

  constant ibaddr_kw11p : slv16 := slv(to_unsigned(8#172540#,16));

  constant ibaddr_csr : slv2 := "00";   -- csr address offset
  constant ibaddr_csb : slv2 := "01";   -- csb address offset
  constant ibaddr_ctr : slv2 := "10";   -- ctr address offset

  constant csr_ibf_err :    integer := 15;
  constant csr_ibf_ir :     integer := 10;
  subtype  csr_ibf_erate    is integer range 9 downto 8;
  constant csr_ibf_done :   integer :=  7;
  constant csr_ibf_ie :     integer :=  6;
  constant csr_ibf_fix :    integer :=  5;
  constant csr_ibf_updn :   integer :=  4;
  constant csr_ibf_mode :   integer :=  3;
  subtype  csr_ibf_rate     is integer range 2 downto 1;
  constant csr_ibf_run :    integer :=  0;
  
  constant rate_100k : slv2 :=  "00";
  constant rate_10k  : slv2 :=  "01";
  constant rate_line : slv2 :=  "10";
  constant rate_ext  : slv2 :=  "11";
  
  constant erate_sclk : slv2 :=  "00";
  constant erate_usec : slv2 :=  "01";
  constant erate_ext  : slv2 :=  "10";
  constant erate_noop : slv2 :=  "11";

  constant dwidth : natural  :=  4;     -- decade divider
  constant ddivide : natural := 10;
  constant lwidth : natural  :=  5;     -- msec -> 50 Hz divider
  constant ldivide : natural := 20;
  
  constant ctrzero : slv16 := (others=>'0');

  type regs_type is record              -- state registers
    ibsel : slbit;                      -- ibus select    
    erate : slv2;                       -- ext rate mode
    err : slbit;                        -- re-interrupt error
    done : slbit;                       -- counter wrap occured
    ie : slbit;                         -- interrupt enable
    updn : slbit;                       -- 0=count-down; 1=count-up
    mode : slbit;                       -- 0=single; 1=repeated interrupt
    rate : slv2;                        -- 00=100kHz;01=10kHz;10=line;11=event
    run : slbit;                        -- enable counter
    csb : slv16;                        -- interval count
    ctr : slv16;                        -- clock counter
    intreq : slbit;                     -- interrupt request
    lcnt : slv(lwidth-1 downto 0);      -- line clock divider
    d1cnt : slv(dwidth-1 downto 0);     -- usec -> 100 kHz divider
    d2cnt : slv(dwidth-1 downto 0);     -- 100->10 kHz divider
    evt100k : slbit;                    -- evt flag: 100 kHz
    evt10k  : slbit;                    -- evt flag: 10 kHz
    evtline : slbit;                    -- evt flag: line clock
    evtext  : slbit;                    -- evt flag: external event
    evtfix  : slbit;                    -- evt flag: csr FIX
    evtload : slbit;                    -- evt flag: load from csb
  end record regs_type;

  constant regs_init : regs_type := (
    '0',                                -- ibsel
    "00",                               -- erate
    '0','0','0','0','0',                -- err,done,ie,updn,mode
    "00",'0',                           -- rate,run
    (others=>'0'),                      -- csb
    (others=>'0'),                      -- ctr
    '0',                                -- intreq
    (others=>'0'),                      -- lcnt
    (others=>'0'),                      -- d1cnt
    (others=>'0'),                      -- d2cnt
    '0','0','0','0',                    -- evt100k,evt10k,evtline,evyevt
    '0','0'                             -- evtfix,evtload
  );

  signal R_REGS : regs_type := regs_init;
  signal N_REGS : regs_type := regs_init;

begin
  
  proc_regs: process (CLK)
  begin
    if rising_edge(CLK) then
      if BRESET = '1' then             -- BRESET is 1 for system and ibus reset
        R_REGS <= regs_init;
        if RESET = '0' then               -- if RESET=0 we do just an ibus reset
          R_REGS.erate <= N_REGS.erate;      -- keep ERATE field
          R_REGS.lcnt  <= N_REGS.lcnt;       -- don't clear clock dividers
          R_REGS.d1cnt <= N_REGS.d1cnt;      -- "
          R_REGS.d2cnt <= N_REGS.d2cnt;      -- "
        end if;
      else
        R_REGS <= N_REGS;
      end if;
    end if;
  end process proc_regs;

  proc_next : process (R_REGS, IB_MREQ, CE_USEC, CE_MSEC,
                       EXTEVT, CPUSUSP, EI_ACK)
    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;
    variable idout : slv16 := (others=>'0');
    variable ibreq : slbit := '0';
    variable ibrd : slbit := '0';
    variable ibwr : slbit := '0';
    variable ievt : slbit := '0';
  begin

    r := R_REGS;
    n := R_REGS;

    idout := (others=>'0');
    ibreq := IB_MREQ.re or IB_MREQ.we;
    ibrd  := IB_MREQ.re;
    ibwr  := IB_MREQ.we;
    
    ievt  := '0';

    n.evtext  := '0';
    case r.erate is
      when erate_sclk => n.evtext := '1';
      when erate_usec => n.evtext := CE_USEC;
      when erate_ext  => n.evtext := EXTEVT;
      when erate_noop => n.evtext := '0';
      when others => null;
    end case;
    n.evt100k := '0';                   -- one shot
    n.evt10k  := '0';                   -- one shot
    n.evtline := '0';                   -- one shot
    n.evtfix  := '0';                   -- one shot
    n.evtload := '0';                   -- one shot
      
    -- ibus address decoder
    n.ibsel := '0';
    if IB_MREQ.aval='1' and
      IB_MREQ.addr(12 downto 3)=ibaddr_kw11p(12 downto 3) and -- is in  17254*
      IB_MREQ.addr(2 downto 1) /= "11" then                   -- is not *****6
      n.ibsel := '1';
    end if;

    -- ibus transactions
    if r.ibsel='1' then
      case IB_MREQ.addr(2 downto 1) is
        when ibaddr_csr =>              -- CSR -- control and status ---------
          idout(csr_ibf_err)  := r.err;
          idout(csr_ibf_done) := r.done;
          idout(csr_ibf_ie)   := r.ie;
          idout(csr_ibf_updn) := r.updn;
          idout(csr_ibf_mode) := r.mode;
          idout(csr_ibf_rate) := r.rate;
          idout(csr_ibf_run)  := r.run;
          if ibrd='1' then
            n.err  := '0';                -- err  is read and clear
            n.done := '0';                -- done is read and clear
          end if;

          if IB_MREQ.racc = '0' then      -- cpu ---------------------
            if ibwr = '1' then
              n.evtfix := IB_MREQ.din(csr_ibf_fix);
              n.ie     := IB_MREQ.din(csr_ibf_ie);
              n.updn   := IB_MREQ.din(csr_ibf_updn);
              n.mode   := IB_MREQ.din(csr_ibf_mode);
              n.rate   := IB_MREQ.din(csr_ibf_rate);
              n.run    := IB_MREQ.din(csr_ibf_run);
              if IB_MREQ.din(csr_ibf_ie)='0' then
                n.intreq := '0';
              end if;
            end if;

          else                            -- rri ---------------------
            idout(csr_ibf_ir)    := r.intreq;
            idout(csr_ibf_erate) := r.erate;
            if ibwr = '1' then
              n.erate   := IB_MREQ.din(csr_ibf_erate);
            end if;
          end if;
          
        when ibaddr_csb =>              -- CSB -- count set buffer -----------
          idout := (others=>'0');         -- csb is not readable, return zero !
          if IB_MREQ.racc = '0' then      -- cpu ---------------------
            if ibwr = '1' then
              n.csb := IB_MREQ.din;
              n.evtload := '1';
            end if;
          end if;

        when ibaddr_ctr =>              -- CTR -- counter --------------------
          idout := r.ctr;

        when others => null;
      end case;
    end if;

    -- other state changes
    --   clock dividers
    if CPUSUSP='0' then                 -- advance if not suspended
      if CE_MSEC='1' then                 -- on msec
        n.lcnt := slv(unsigned(r.lcnt) + 1);
        if unsigned(r.lcnt) = ldivide-1 then
          n.lcnt := (others=>'0');
          n.evtline := '1';
        end if;
      end if;
      
      if CE_USEC='1' then                 -- on usec
        n.d1cnt := slv(unsigned(r.d1cnt) + 1);
        if unsigned(r.d1cnt) = ddivide-1 then
          n.d1cnt := (others=>'0');
          n.evt100k := '1';
          n.d2cnt := slv(unsigned(r.d2cnt) + 1);
          if unsigned(r.d2cnt) = ddivide-1 then
            n.d2cnt := (others=>'0');
            n.evt10k := '1';
          end if;
        end if;
      end if;
    end if;
    
    --   counter logic
    --     select source
    if r.run='1' then
      case r.rate is
        when rate_100k => ievt := r.evt100k;
        when rate_10k  => ievt := r.evt10k;
        when rate_line => ievt := r.evtline;
        when rate_ext  => ievt := r.evtext;
        when others => null;
      end case;
    else
      ievt := r.evtfix;
    end if;

    --     load or action
    if r.evtload='1' then               -- load
      n.ctr := r.csb;
      
    else                                -- action
      if ievt='1' then                    -- count event ?
        if r.updn='0' then                  -- count-down
          n.ctr := slv(unsigned(r.ctr) - 1);
        else                                -- count-up
          n.ctr := slv(unsigned(r.ctr) + 1);
        end if;

        if n.ctr=ctrzero then             -- zero reached ?
          n.done := '1';                      -- set done
          if r.done='1' then                  -- already done
            n.err := '1';                       -- set error
          end if;

          if r.ie = '1' then                  -- interrupt enabled ?
            n.intreq := '1';
          end if;
          
          if r.mode='1' then                  -- mode: repeat
            n.ctr := r.csb;
          else                                -- mode: single shot
            n.csb := ctrzero;
            n.run := '0';
          end if;
          
        end if;
        
      end if; -- if ievt='1'
    end if;  -- if  r.evtload='1'
    
    if EI_ACK = '1' then
      n.intreq := '0';
    end if;
    
    N_REGS <= n;

    IB_SRES.dout <= idout;
    IB_SRES.ack  <= r.ibsel and ibreq;
    IB_SRES.busy <= '0';
    
    EI_REQ <= r.intreq;
    
  end process proc_next;
  
end syn;
