-- $Id: ibdr_deuna.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2014-2017 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    ibdr_deuna - syn
-- Description:    ibus dev(rem): DEUNA
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  ise 14.7; viv 2016.4-2017.1; ghdl 0.33-0.34
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2017-05-06   894 14.7  131013 xc6slx16-2    53   92    0   42 s  4.4
-- 2017-04-14   874 14.7  131013 xc6slx16-2    50   79    0   40 s  4.1
-- 2017-01-29   847 14.7  131013 xc6slx16-2    42   70    0   36 s  4.1
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2017-05-06   894   1.0    Initial version (full functionality)
-- 2017-04-14   875   0.5    Initial version (partial functionality)
-- 2014-06-09   561   0.1    First draft 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.iblib.all;

-- ----------------------------------------------------------------------------
entity ibdr_deuna is                    -- ibus dev(rem): DEUNA
                                        -- fixed address: 174510
  port (
    CLK : in slbit;                     -- clock
    BRESET : in slbit;                  -- ibus reset
    RB_LAM : out slbit;                 -- remote attention
    IB_MREQ : in ib_mreq_type;          -- ibus request
    IB_SRES : out ib_sres_type;         -- ibus response
    EI_REQ : out slbit;                 -- interrupt request
    EI_ACK : in slbit                   -- interrupt acknowledge
  );
end ibdr_deuna;

architecture syn of ibdr_deuna is

  constant ibaddr_deuna : slv16 := slv(to_unsigned(8#174510#,16));

  constant ibaddr_pr0 : slv2 := "00";     -- pcsr0 address offset
  constant ibaddr_pr1 : slv2 := "01";     -- pcsr1 address offset
  constant ibaddr_pr2 : slv2 := "10";     -- pcsr2 address offset
  constant ibaddr_pr3 : slv2 := "11";     -- pcsr3 address offset
  
  constant pr0_ibf_seri  : integer := 15;
  constant pr0_ibf_pcei  : integer := 14;
  constant pr0_ibf_rxi   : integer := 13;
  constant pr0_ibf_txi   : integer := 12;
  constant pr0_ibf_dni   : integer := 11;
  constant pr0_ibf_rcbi  : integer := 10;
  constant pr0_ibf_usci  : integer :=  8;
  constant pr0_ibf_intr  : integer :=  7;
  constant pr0_ibf_inte  : integer :=  6;
  constant pr0_ibf_rset  : integer :=  5;
  subtype  pr0_ibf_pcmd    is integer range  3 downto  0;
  -- additional rem view assignments
  subtype  pr0_ibf_pcmdbp  is integer range 15 downto 12;
  constant pr0_ibf_pdmdwb: integer := 10;
  constant pr0_ibf_busy  : integer :=  9;
  constant pr0_ibf_pcwwb : integer :=  8;
  constant pr0_ibf_brst  : integer :=  4;
  
  constant pcmd_noop : slv4 := "0000";   -- pcmd: noop (DNI not set !)
  constant pcmd_pdmd : slv4 := "1000";   -- pcmd: pdmd 

  constant pr1_ibf_xpwr  : integer := 15;
  constant pr1_ibf_icab  : integer := 14;
  subtype  pr1_ibf_ecod    is integer range 13 downto  8;
  constant pr1_ibf_pcto  : integer :=  7;
  constant pr1_ibf_deuna : integer :=  4;  -- id bit 0 (0=DEUNA;1=DELUA)
  subtype  pr1_ibf_state   is integer range  3 downto  0;

  constant state_reset : slv4 := "0000";   -- state: reset
  constant state_ready : slv4 := "0010";   -- state: ready

  type regs_type is record              -- state registers
    ibsel    : slbit;                   -- ibus select
    pr0seri  : slbit;                   -- pr0: status error intr
    pr0pcei  : slbit;                   -- pr0: port command error intr
    pr0rxi   : slbit;                   -- pr0: receive ring intr
    pr0txi   : slbit;                   -- pr0: transmit ring intr
    pr0dni   : slbit;                   -- pr0: done interrupt
    pr0rcbi  : slbit;                   -- pr0: receive buffer unavail intr
    pr0usci  : slbit;                   -- pr0: unsolicited state change intr
    pr0intr  : slbit;                   -- pr0: intr summary
    pr0inte  : slbit;                   -- pr0: intr enable
    pr0rset  : slbit;                   -- pr0: software reset
    pr0brst  : slbit;                   -- pr0: BRESET reset
    pr0pcmd  : slv4;                    -- pr0: port command
    pr1xpwr  : slbit;                   -- pr1: transmitter power fail
    pr1icab  : slbit;                   -- pr1: port/link cabling fail
    pr1pcto  : slbit;                   -- pr1: port command time out
    pr1deuna : slbit;                   -- pr1: bit 0 of ID (0=DEUNA;1=DELUA)
    pr1state : slv4;                    -- pr1: port status
    pcbb     : slv18_1;                 -- pr2+3: port conrol block base
    pdmdwb   : slbit;                   -- restart for pdmd while busy
    busy     : slbit;                   -- busy
    pcmdwwb  : slbit;                   -- pcmd written while busy
    pcmdbp   : slv4;                    -- pcmd busy protected
    resreq   : slbit;                   -- reset requested
    ireq     : slbit;                   -- interrupt request flag
  end record regs_type;

  constant regs_init : regs_type := (
    '0',                                -- ibsel
    '0','0','0','0',                    -- pr0seri,pr0pcei,pr0rxi,pr0txi
    '0','0','0',                        -- pr0dni,pr0rcbi,pr0usci
    '0','0',                            -- pr0intr,pr0inte
    '0','0',                            -- pr0rset,pr0brst
    (others=>'0'),                      -- pr0pcmd
    '1','1',                            -- pr1xpwr,pr1icab
    '0','0',                            -- pr1pcto,pr1deuna
    state_reset,                        -- pr1state
    (others=>'0'),                      -- pcbb
    '0','0','0',                        -- pdmdwb,busy,pcmdwwb
    (others=>'0'),                      -- pcmdbp
    '0',                                -- resreq
    '0'                                 -- ireq
  );

  signal R_REGS : regs_type := regs_init;
  signal N_REGS : regs_type := regs_init;

begin
  
  proc_regs: process (CLK)
  begin
    if rising_edge(CLK) then
      R_REGS <= N_REGS;
    end if;
  end process proc_regs;

  proc_next : process (R_REGS, IB_MREQ, BRESET)
    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;
    variable ibhold : slbit := '0';
    variable idout  : slv16 := (others=>'0');
    variable ibrem  : slbit := '0';
    variable ibreq  : slbit := '0';
    variable ibrd   : slbit := '0';
    variable ibw0   : slbit := '0';
    variable ibw1   : slbit := '0';
    variable ibwrem : slbit := '0';
    variable ilam   : slbit := '0';
    
  begin

    r := R_REGS;
    n := R_REGS;

    ibhold := '0';
    idout  := (others=>'0');
    ibrem  := IB_MREQ.racc;
    ibreq  := IB_MREQ.re or IB_MREQ.we;
    ibrd   := IB_MREQ.re;
    ibw0   := IB_MREQ.we and IB_MREQ.be0;
    ibw1   := IB_MREQ.we and IB_MREQ.be1;
    ibwrem := IB_MREQ.we and ibrem;
    ilam   := '0';
    
    -- ibus address decoder
    n.ibsel := '0';
    if IB_MREQ.aval = '1' and
       IB_MREQ.addr(12 downto 3)=ibaddr_deuna(12 downto 3) then
      n.ibsel := '1';
    end if;

    -- ibus transactions
    
    if r.ibsel='1' then                 -- selected
        
      case IB_MREQ.addr(2 downto 1) is

        when ibaddr_pr0 =>              -- PCSR0 - intr and pcmd -----------
          if ibrem = '0' then             -- loc view of upper byte
            idout(pr0_ibf_seri)   := r.pr0seri;
            idout(pr0_ibf_pcei)   := r.pr0pcei;
            idout(pr0_ibf_rxi)    := r.pr0rxi;
            idout(pr0_ibf_txi)    := r.pr0txi;
            idout(pr0_ibf_dni)    := r.pr0dni;
            idout(pr0_ibf_rcbi)   := r.pr0rcbi;
            idout(pr0_ibf_usci)   := r.pr0usci;
          else                            -- rem view of upper byte
            idout(pr0_ibf_pcmdbp) := r.pcmdbp;
            idout(pr0_ibf_pdmdwb) := r.pdmdwb;
            idout(pr0_ibf_busy)   := r.busy;
            idout(pr0_ibf_pcwwb)  := r.pcmdwwb;
          end if;
          idout(pr0_ibf_intr)  := r.pr0intr;
          idout(pr0_ibf_inte)  := r.pr0inte;
          if ibrem = '1' then
            idout(pr0_ibf_rset)  := r.pr0rset;  -- only seen from rem side
            idout(pr0_ibf_brst)  := r.pr0brst;  -- only seen from rem side
          end if;
          idout(pr0_ibf_pcmd)  := r.pr0pcmd;

          if IB_MREQ.we = '1' then
            if ibrem = '1' then           -- rem write
              if IB_MREQ.din(pr0_ibf_seri) = '1' then n.pr0seri := '1'; end if;
              if IB_MREQ.din(pr0_ibf_pcei) = '1' then
                n.pcmdwwb := '0';
                n.pdmdwb  := '0';
                n.busy    := '0';
                n.pr0pcei := '1';
              end if;
              if IB_MREQ.din(pr0_ibf_rxi)  = '1' then n.pr0rxi  := '1'; end if;
              if IB_MREQ.din(pr0_ibf_txi)  = '1' then n.pr0txi  := '1'; end if;
              if IB_MREQ.din(pr0_ibf_dni)  = '1' then
                n.pcmdwwb := '0';
                n.pdmdwb  := '0';
               -- if pdmd issued while busy, restart with pdmd, else end pcmd
               if r.pcmdwwb = '1' and r.pr0pcmd = pcmd_pdmd then
                  n.pcmdbp := pcmd_pdmd;
                  n.pdmdwb := '1';
                  ilam     := '1';            -- rri lam: restart with pdmd
                else
                  n.busy    := '0';
                  n.pr0dni  := '1';
                end if;
              end if;
              if IB_MREQ.din(pr0_ibf_rcbi) = '1' then n.pr0rcbi := '1'; end if;
              if IB_MREQ.din(pr0_ibf_busy) = '1' then n.busy := '0';    end if;
              if IB_MREQ.din(pr0_ibf_usci) = '1' then n.pr0usci := '1'; end if;
              if IB_MREQ.din(pr0_ibf_rset) = '1' then
                n.busy := '0';
                n.pr0rset := '0';
              end if;
              if IB_MREQ.din(pr0_ibf_brst) = '1' then
                n.busy := '0';
                n.pr0brst := '0';
              end if;
              
            else                          -- loc write
              if IB_MREQ.be1 = '1' then
                if IB_MREQ.din(pr0_ibf_seri) = '1' then n.pr0seri := '0'; end if;
                if IB_MREQ.din(pr0_ibf_pcei) = '1' then n.pr0pcei := '0'; end if;
                if IB_MREQ.din(pr0_ibf_rxi)  = '1' then n.pr0rxi  := '0'; end if;
                if IB_MREQ.din(pr0_ibf_txi)  = '1' then n.pr0txi  := '0'; end if;
                if IB_MREQ.din(pr0_ibf_dni)  = '1' then n.pr0dni  := '0'; end if;
                if IB_MREQ.din(pr0_ibf_rcbi) = '1' then n.pr0rcbi := '0'; end if;
                if IB_MREQ.din(pr0_ibf_usci) = '1' then n.pr0usci := '0'; end if;
              end if;
              if IB_MREQ.be0 = '1' then
                if IB_MREQ.din(pr0_ibf_rset) = '1' then -- RESET requested ?
                  n.resreq   := '1';
                  n.pr0rset  := '1';
                elsif IB_MREQ.din(pr0_ibf_inte) /= r.pr0inte then -- INTE change?
                    n.pr0inte := IB_MREQ.din(pr0_ibf_inte);
                    n.pr0dni  := '1';
                elsif r.pr1state /=  state_reset then   -- not in reset
                  n.pr0pcmd := IB_MREQ.din(pr0_ibf_pcmd);
                  if r.busy = '0' then           -- if not busy execute
                    n.pcmdbp := IB_MREQ.din(pr0_ibf_pcmd);
                    if IB_MREQ.din(pr0_ibf_pcmd) /= pcmd_noop then
                      n.busy := '1';            -- signal busy
                      ilam   := '1';            -- rri lam
                    end if;
                  else                            -- if busy set pcmdwwf flag
                    n.pcmdwwb := '1';
                  end if;
                end if; 
              end if; -- if IB_MREQ.be0 = '1'
            end if; -- else ibrem = '1'
          end if; -- if IB_MREQ.we = '1'
          
        when ibaddr_pr1 =>              -- PCSR1 - status ------------------
          idout(pr1_ibf_xpwr)  := r.pr1xpwr;
          idout(pr1_ibf_icab)  := r.pr1icab;
          idout(pr1_ibf_pcto)  := r.pr1pcto;
          idout(pr1_ibf_deuna) := r.pr1deuna;
          idout(pr1_ibf_state) := r.pr1state;
          if IB_MREQ.we = '1' then
            if ibrem = '1' then
              n.pr1xpwr  := IB_MREQ.din(pr1_ibf_xpwr);
              n.pr1icab  := IB_MREQ.din(pr1_ibf_icab);
              n.pr1pcto  := IB_MREQ.din(pr1_ibf_pcto);
              n.pr1deuna := IB_MREQ.din(pr1_ibf_deuna);
              n.pr1state := IB_MREQ.din(pr1_ibf_state);
            end if;
          end if;

        when ibaddr_pr2 =>              -- PCSR2 - pcbb low order ----------
          idout(15 downto  1)   := r.pcbb(15 downto  1);
          if IB_MREQ.we = '1' then
            n.pcbb(15 downto  1) := IB_MREQ.din(15 downto  1);
          end if;

        when ibaddr_pr3 =>              -- PCSR2 - pcbb high order ---------
          idout( 1 downto  0)   := r.pcbb(17 downto 16);
          if IB_MREQ.we = '1' then
            n.pcbb(17 downto 16) := IB_MREQ.din( 1 downto  0);
          end if;

      when others => null;
          
      end case;
    end if;
    
    if BRESET = '1' then
      n.resreq   := '1';
      n.pr0brst  := '1';
    end if;
    
    if r.resreq = '1' then 
      n.pr0seri := '0';
      n.pr0pcei := '0';
      n.pr0rxi  := '0';
      n.pr0txi  := '0';
      n.pr0dni  := '0';
      n.pr0rcbi := '0';
      n.pr0usci := '0';
      n.pr1pcto := '0';
      n.pr0inte := '0';
      n.pr1state := state_reset;
      n.pcbb    := (others => '0');
      n.resreq  := '0';
      -- send lam on soft or bus reset only when not in state_reset
      -- the startup default is state_reset, so without active backend
      -- this device will not send lam's on bus resets
      if r.pr1state /=  state_reset then
        n.busy := '1';        -- signal busy
        ilam   := '1';        -- rri lam unless reset handling pending
      end if;
        
    end if;

    n.pr0intr := r.pr0seri or r.pr0pcei or r.pr0rxi or r.pr0txi or
                 r.pr0dni  or r.pr0rcbi or r.pr0usci;

    if r.pr0inte = '1' then
      n.ireq := r.pr0intr;
    else
      n.ireq := '0';
    end if;
    
    N_REGS <= n;

    IB_SRES.dout <= idout;
    IB_SRES.ack  <= r.ibsel and ibreq;
    IB_SRES.busy <= ibhold  and ibreq;

    RB_LAM <= ilam;
    EI_REQ <= r.ireq;
    
  end process proc_next;

    
end syn;
