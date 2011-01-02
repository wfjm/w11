-- $Id: pdp11_core_rbus.vhd 352 2011-01-02 13:01:37Z mueller $
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
-- Module Name:    pdp11_core_rbus - syn
-- Description:    pdp11: core to rbus interface
--
-- Dependencies:   -
-- Test bench:     tb/tb_rlink_tba_pdp11core
--
-- Target Devices: generic
-- Tool versions:  xst 8.1, 8.2, 9.1, 9.2, 11.4, 12.1; ghdl 0.18-0.26
-- Revision History: -
-- Date         Rev Version  Comment
-- 2010-12-29   351   1.1    renamed from pdp11_core_rri; ported to rbv3
-- 2010-10-23   335   1.2.3  rename RRI_LAM->RB_LAM;
-- 2010-06-20   308   1.2.2  use c_ibrb_ibf_ def's
-- 2010-06-18   306   1.2.1  rename RB_ADDR->RB_ADDR_CORE, add RB_ADDR_IBUS;
--                           add ibrb register and ibr window logic
-- 2010-06-13   305   1.2    add CP_ADDR in port; mostly rewritten for new
--                           rri <-> cp mapping
-- 2010-06-03   299   1.1.2  correct rbus init logic (use we, din, RB_ADDR)
-- 2010-05-02   287   1.1.1  rename RP_STAT->RB_STAT; remove unneeded unsigned()
-- 2010-05-01   285   1.1    port to rri V2 interface, add RB_ADDR generic;
--                           rename c_rp_addr_* -> c_rb_addr_*
-- 2008-05-03   143   1.0.8  rename _cpursta->_cpurust
-- 2008-04-27   140   1.0.7  use cpursta interface, remove cpufail
-- 2008-03-02   121   1.0.6  set RP_ERR when cmderr or cmdmerr status seen
-- 2008-02-24   119   1.0.5  support lah,rps,wps cp commands
-- 2008-01-20   113   1.0.4  use single LAM; change to RRI_LAM interface
-- 2007-10-12    88   1.0.3  avoid ieee.std_logic_unsigned, use cast to unsigned
-- 2007-08-16    74   1.0.2  add AP_LAM interface to pdp11_core_rri
-- 2007-08-12    73   1.0.1  use def's; add stat command; wait for step complete
-- 2007-07-08    65   1.0    Initial version 
------------------------------------------------------------------------------
--
-- rbus registers:
--
-- Address   Bits Name        r/w/i  Function
--
-- bbb00000       conf        r/w/-  cpu configuration (e.g. cpu type)
--                                   (currently unused, all bits MBZ)
-- bbb00001       cntl        -/f/-  cpu control
--            3:0   func               function code
--                                       0000: noop
--                                       0001: start
--                                       0010: stop
--                                       0011: continue
--                                       0100: step
--                                       1111: reset (soft)
-- bbb00010       stat        r/-/-  cpu status
--           7:04   cpurust   r/-/-    cp_stat: cpurust
--              3   cpuhalt   r/-/-    cp_stat: cpuhalt
--              2   cpugo     r/-/-    cp_stat: cpugo
--              1   cmdmerr   r/-/-    cp_stat: cmdmerr
--              0   cmderr    r/-/-    cp_stat: cmderr
-- bbb00011       psw         r/w/-  processor status word access
-- bbb00100       al          r/w/-  address register, low
-- bbb00101       ah          r/w/-  address register, high
-- bbb00110       mem         r/w/-  memory access
-- bbb00111       memi        r/w/-  memory access, inc address
-- bbb01rrr       gpr[]       r/w/-  general purpose regs
-- bbb10000       ibrb        r/w/-  ibr base address
--          12:06   base      r/w/-    ibr window base address
--           1:00   we        r/w/-    byte enables (00 equivalent to 11)
-- www-----       ibr[]       r/w/-  ibr window (32 words)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

use work.slvtypes.all;
use work.rblib.all;
use work.pdp11.all;

-- ----------------------------------------------------------------------------

entity pdp11_core_rbus is               -- core to rbus interface
  generic (
    RB_ADDR_CORE : slv8 := conv_std_logic_vector(2#00000000#,8);
    RB_ADDR_IBUS : slv8 := conv_std_logic_vector(2#10000000#,8));
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : out rb_sres_type;         -- rbus: response
    RB_STAT : out slv3;                 -- rbus: status flags
    RB_LAM : out slbit;                 -- remote attention
    CPU_RESET : out slbit;              -- cpu master reset
    CP_CNTL : out cp_cntl_type;         -- console control port
    CP_ADDR : out cp_addr_type;         -- console address port
    CP_DIN : out slv16;                 -- console data in
    CP_STAT : in cp_stat_type;          -- console status port
    CP_DOUT : in slv16                  -- console data out
  );
end pdp11_core_rbus;


architecture syn of pdp11_core_rbus is

  type state_type is (
    s_idle,                             -- s_idle: wait for rp access
    s_cpwait,                           -- s_cpwait: wait for cp port ack
    s_cpstep                            -- s_cpstep: wait for cpustep done
  );
  
  type regs_type is record
    state : state_type;                 -- state
    rbselc : slbit;                     -- rbus select for core
    rbseli : slbit;                     -- rbus select for ibus
    cpreq : slbit;                      -- cp request flag
    cpfunc : slv5;                      -- cp function
    cpugo_1 : slbit;                    -- prev cycle cpugo
    addr : slv22_1;                     -- address register
    ena_22bit : slbit;                  -- 22bit enable
    ena_ubmap : slbit;                  -- ubmap enable
    ibrbase : slv(c_ibrb_ibf_base);     -- ibr base address
    ibrbe : slv2;                       -- ibr byte enables
    ibrberet : slv2;                    -- ibr byte enables (for readback)
    doinc : slbit;                      -- at cmdack: do addr reg inc
    waitstep : slbit;                   -- at cmdack: wait for cpu step complete
  end record regs_type;

  constant regs_init : regs_type := (
    s_idle,                             -- state
    '0','0',                            -- rbselc,rbseli
    '0',                                -- cpreq
    (others=>'0'),                      -- cpfunc
    '0',                                -- cpugo_1
    (others=>'0'),                      -- addr
    '0','0',                            -- ena_22bit, ena_ubmap
    (others=>'0'),"00","00",            -- ibrbase, ibrbe, ibrberet
    '0','0'                             -- doinc, waitstep
  );

  signal R_REGS : regs_type := regs_init;  -- state registers
  signal N_REGS : regs_type := regs_init;  -- next value state regs

  begin
    
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

  proc_next: process (R_REGS, RB_MREQ, CP_STAT, CP_DOUT)

    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;

    variable irb_ack  : slbit := '0';
    variable irb_busy : slbit := '0';
    variable irb_err  : slbit := '0';
    variable irb_dout : slv16 := (others=>'0');
    variable irb_lam  : slbit := '0';
    variable irbena   : slbit := '0';

    variable icpreq    : slbit := '0';
    variable icpureset : slbit := '0';
    variable icpaddr   : cp_addr_type := cp_addr_init;
    
  begin

    r := R_REGS;
    n := R_REGS;

    irb_ack  := '0';
    irb_busy := '0';
    irb_err  := '0';
    irb_dout := (others=>'0');
    irb_lam  := '0';

    irbena  := RB_MREQ.re or RB_MREQ.we;

    icpreq    := '0';
    icpureset := '0';

    -- look for init's against the rbus base address, generate subsystem resets
    if RB_MREQ.init='1' and RB_MREQ.we='1' and RB_MREQ.addr=RB_ADDR_CORE then
      icpureset := RB_MREQ.din(0);
    end if;    

    -- rbus address decoder
    n.rbseli := '0';
    n.rbselc := '0';
    if RB_MREQ.aval='1' then
      if RB_MREQ.addr(7 downto 5)=RB_ADDR_CORE(7 downto 5) then
        n.rbselc := '1';
      end if;
      if RB_MREQ.addr(7 downto 5)=RB_ADDR_IBUS(7 downto 5) then
        n.rbseli := '1';
      end if;
    end if;

    if (r.rbselc='1' or r.rbseli='1') and irbena='1' then
      irb_ack  := '1';                   -- ack all (maybe rejected later)
    end if;
    
    case r.state is

      when s_idle =>                    -- s_idle: wait for rbus access ------

        n.doinc    := '0';
        n.waitstep := '0';
        
        if r.rbseli = '1' then
          if irbena = '1' then
            n.cpfunc    := c_cpfunc_rmem;
            n.cpfunc(0) := RB_MREQ.we;
            icpreq := '1';
          end if;

        elsif r.rbselc = '1' then

          case RB_MREQ.addr(4 downto 0) is

            when c_rbaddr_conf =>         -- conf -------------------------
              null;                         -- currently no action

            when c_rbaddr_cntl =>         -- cntl -------------------------
              if irbena = '1' then
                n.cpfunc := RB_MREQ.din(n.cpfunc'range);
              end if;
              if RB_MREQ.we = '1' then
                icpreq := '1';
                if RB_MREQ.din(3 downto 0) = c_cpfunc_step(3 downto 0) then
                  n.waitstep := '1';
                end if;
              end if;
                
            when c_rbaddr_stat =>         -- stat -------------------------
              irb_dout(c_stat_rbf_cmderr)  := CP_STAT.cmderr;
              irb_dout(c_stat_rbf_cmdmerr) := CP_STAT.cmdmerr;
              irb_dout(c_stat_rbf_cpugo)   := CP_STAT.cpugo;
              irb_dout(c_stat_rbf_cpuhalt) := CP_STAT.cpuhalt;
              irb_dout(c_stat_rbf_cpurust) := CP_STAT.cpurust;

            when c_rbaddr_psw  =>         -- psw --------------------------
              if irbena = '1' then
                n.cpfunc    := c_cpfunc_rpsw;
                n.cpfunc(0) := RB_MREQ.we;
                icpreq := '1';
              end if;
              
            when c_rbaddr_al   =>         -- al ---------------------------
              irb_dout(c_al_rbf_addr) := r.addr(c_al_rbf_addr);
              if RB_MREQ.we = '1' then
                n.addr      := (others=>'0'); -- write to al clears ah !!
                n.ena_22bit := '0';
                n.ena_ubmap := '0';
                n.addr(c_al_rbf_addr) := RB_MREQ.din(c_al_rbf_addr);
              end if;

            when c_rbaddr_ah   =>         -- ah ---------------------------
              irb_dout(c_ah_rbf_ena_ubmap) := r.ena_ubmap;
              irb_dout(c_ah_rbf_ena_22bit) := r.ena_22bit;
              irb_dout(c_ah_rbf_addr)      := r.addr(21 downto 16);
              if RB_MREQ.we = '1' then
                n.addr(21 downto 16) := RB_MREQ.din(c_ah_rbf_addr);
                n.ena_22bit          := RB_MREQ.din(c_ah_rbf_ena_22bit);
                n.ena_ubmap          := RB_MREQ.din(c_ah_rbf_ena_ubmap);
              end if;

            when c_rbaddr_mem  =>         -- mem -----------------
              if irbena = '1' then
                n.cpfunc    := c_cpfunc_rmem;
                n.cpfunc(0) := RB_MREQ.we;
                icpreq   := '1';
              end if;
              
            when c_rbaddr_memi  =>        -- memi ----------------
              if irbena = '1' then
                n.cpfunc    := c_cpfunc_rmem;
                n.cpfunc(0) := RB_MREQ.we;
                n.doinc  := '1';
                icpreq   := '1';
              end if;
              
            when c_rbaddr_r0 | c_rbaddr_r1 |
                 c_rbaddr_r2 | c_rbaddr_r3 |
                 c_rbaddr_r4 | c_rbaddr_r5 |
                 c_rbaddr_sp | c_rbaddr_pc =>      -- r* ------------------
              if irbena = '1' then
                n.cpfunc    := c_cpfunc_rreg;
                n.cpfunc(0) := RB_MREQ.we;
                icpreq   := '1';
              end if;
              
            when c_rbaddr_ibrb  =>        -- ibrb ----------------
              irb_dout(c_ibrb_ibf_base) := r.ibrbase;
              irb_dout(c_ibrb_ibf_be)   := r.ibrberet;
              if RB_MREQ.we = '1' then
                n.ibrbase  := RB_MREQ.din(c_ibrb_ibf_base);
                n.ibrberet := RB_MREQ.din(c_ibrb_ibf_be);
                if RB_MREQ.din(c_ibrb_ibf_be) = "00" then -- both be=0 ?
                  n.ibrbe := "11";
                else                               -- otherwise take 2 LSB's
                  n.ibrbe := RB_MREQ.din(c_ibrb_ibf_be);
                end if;
              end if;
              
            when others =>
              irb_ack := '0';

          end case;

        end if; 
        
        if icpreq = '1' then
          irb_busy := '1';
          n.cpreq  := '1';
          n.state  := s_cpwait;              
        end if;          
          
      when s_cpwait =>                  -- s_cpwait: wait for cp port ack ----
        n.cpreq := '0';                   -- cpreq only for 1 cycle

        if (r.rbselc or r.rbseli)='0' or irbena='0' then -- rbus cycle abort
          n.state := s_idle;              -- quit
        else
          irb_dout := CP_DOUT;
          irb_err  := CP_STAT.cmderr or CP_STAT.cmdmerr;
          if CP_STAT.cmdack = '1' then       -- normal cycle end
            if r.doinc = '1' then
              n.addr := unsigned(r.addr) + 1;
            end if;
            if r.waitstep = '1' then
              irb_busy := '1';
              n.state := s_cpstep;            
            else
              n.state := s_idle;
            end if;
          else
            irb_busy := '1';
          end if;
        end if;

      when s_cpstep =>                  -- s_cpstep: wait for cpustep done ---
        if r.rbselc='0' or irbena='0' then -- rbus cycle abort
          n.state := s_idle;                -- quit
        else
          if CP_STAT.cpustep = '0' then      -- cpustep done
            n.state := s_idle;
          else
            irb_busy := '1';
          end if;
        end if;

      when others => null;
    end case;

    icpaddr := cp_addr_init;
    icpaddr.addr      := r.addr;
    icpaddr.racc      := '0';
    icpaddr.be        := "11";
    icpaddr.ena_22bit := r.ena_22bit;
    icpaddr.ena_ubmap := r.ena_ubmap;
      
    if r.rbseli = '1' and irbena = '1' then
      icpaddr.addr(15 downto 13)    := "111";
      icpaddr.addr(c_ibrb_ibf_base) := r.ibrbase;
      icpaddr.addr(5 downto 1)      := RB_MREQ.addr(4 downto 0);
      icpaddr.racc      := '1';
      icpaddr.be        := r.ibrbe;
      icpaddr.ena_22bit := '0';
      icpaddr.ena_ubmap := '0';
    end if;
    
    n.cpugo_1 := CP_STAT.cpugo;         -- delay cpugo 
    if CP_STAT.cpugo='0' and r.cpugo_1='1' then  -- cpugo 1 -> 0 transition ?
      irb_lam := '1';
    end if;
    
    N_REGS <= n;
    
    RB_SRES.ack  <= irb_ack;
    RB_SRES.err  <= irb_err;
    RB_SRES.busy <= irb_busy;
    RB_SRES.dout <= irb_dout;
    
    RB_STAT(0) <= CP_STAT.cpugo;
    RB_STAT(1) <= CP_STAT.cpuhalt or CP_STAT.cpurust(CP_STAT.cpurust'left);
    RB_STAT(2) <= CP_STAT.cmderr  or CP_STAT.cmdmerr;

    RB_LAM     <= irb_lam;

    CPU_RESET  <= icpureset;
    
    CP_CNTL.req  <= r.cpreq;
    CP_CNTL.func <= r.cpfunc;
    CP_CNTL.rnum <= RB_MREQ.addr(2 downto 0);

    CP_ADDR <= icpaddr;
    CP_DIN  <= RB_MREQ.din;
    
  end process proc_next;

end syn;
