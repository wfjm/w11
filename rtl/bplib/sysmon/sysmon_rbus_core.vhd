-- $Id: sysmon_rbus_core.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2016-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    sysmon_rbus_core - syn
-- Description:    SYSMON interface to rbus (generic)
--
-- Dependencies:   -
--
-- Test bench:     -
--
-- Target Devices: generic (all with SYSMON or XADC)
-- Tool versions:  viv 2015.4-2019.1; ghdl 0.33-0.35
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2016-05-25   767   1.0.1  don't init N_REGS (vivado fix for fsm inference)
--                           BUGFIX: use s_init in regs_init (was s_idle)
-- 2016-03-12   741   1.0    Initial version
-- 2016-03-06   738   0.1    First draft
------------------------------------------------------------------------------
--
-- rbus registers:
-- - in general 1-to-1 mapping to sysmon/xadc address space
--   --> see function in sysmon/xadc user guide
-- - 8 addresses are implemented on the controller (base is ibase, default x"78")
--   --> see function below
--
-- Addr   Bits  Name        r/w/f  Function
--  000         cntl        -/-/f  cntl
--          15    reset     -/-/f    reset SYSMON
--  001         stat        r/w/-  stat
--           3    jlock     r/c/-    JTAGLOCKED seen
--           2    jmod      r/c/-    JTAGMODIFIED seen
--           1    jbusy     r/c/-    JTAGBUSY seen
--           0    ot        r/c/-    OT seen
--  010         almh        r/w/-  alm history
--        *:00    alm       r/c/-    ALM(*:0) seen
--  011                     -/-/-  <unused>
--  100         temp        r/-/-  current temp value
--  101         alm         r/-/-  current alm  value
--        *:00   alm        r/-/-    alm(*:0)
--  110                     -/-/-  <unused>
--  111         eos         r/-/-  eos counter    
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.rblib.all;
use work.sysmonrbuslib.all;

-- ----------------------------------------------------------------------------

entity sysmon_rbus_core is              -- SYSMON interface to rbus
  generic (
    DAWIDTH : positive :=  7;           -- drp address bus width
    ALWIDTH : positive :=  8;           -- alm width
    TEWIDTH : positive := 12;           -- temp width
    IBASE   : slv8  := x"78";            -- base of controller register window
    RB_ADDR : slv16 := x"fb00");
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit := '0';            -- reset
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : out rb_sres_type;         -- rbus: response
    SM_DEN : out slbit;                 -- sysmon: drp enable
    SM_DWE : out slbit;                 -- sysmon: drp write enable
    SM_DADDR : out slv(DAWIDTH-1 downto 0);  -- sysmon: drp address
    SM_DI : out slv16;                  -- sysmon: data input
    SM_DO : in slv16;                   -- sysmon: data output
    SM_DRDY : in slbit;                 -- sysmon: data ready
    SM_EOS : in slbit;                  -- sysmon: end of scan
    SM_RESET : out slbit;               -- sysmon: reset
    SM_ALM : in slv(ALWIDTH-1 downto 0);-- sysmon: alarms
    SM_OT : in slbit;                   -- sysmon: overtemperature
    SM_JTAGBUSY : in slbit;             -- sysmon: JTAGBUSY
    SM_JTAGLOCKED : in slbit;           -- sysmon: JTAGLOCKED
    SM_JTAGMODIFIED : in slbit;         -- sysmon: JTAGMODIFIED
    TEMP : out slv(TEWIDTH-1 downto 0)  -- die temp
  );
end sysmon_rbus_core;

architecture syn of sysmon_rbus_core is
  
  type state_type is (
    s_init,                             -- init: wait for jtaglocked down
    s_idle,                             -- idle: dispatch
    s_wait,                             -- wait: wait on drdy
    s_twait                             -- twait: wait on drdy of temp read
  );

  type regs_type is record
    rbsel  : slbit;                     -- rbus select
    state  : state_type;                -- state
    eoscnt : slv16;                     -- eos counter
    stat_ot : slbit;                    -- stat: ot
    stat_jlock : slbit;                 -- stat: jtag locked
    stat_jmod : slbit;                  -- stat: jtag modified
    stat_jbusy : slbit;                 -- stat: jtag busy
    almh : slv(ALWIDTH-1 downto 0);     -- almh
    temp : slv(TEWIDTH-1 downto 0);     -- temp value
    tpend : slbit;                      -- temp pending
  end record regs_type;

  constant regs_init : regs_type := (
    '0',                                -- rbsel
    s_init,                             -- state
    (others=>'0'),                      -- eoscnt
    '0','0','0','0',                    -- stat_ot, stat_j*
    slv(to_unsigned(0,ALWIDTH)),        -- almh
    slv(to_unsigned(0,TEWIDTH)),        -- temp
    '0'                                 -- tpend
  );

  signal R_REGS : regs_type := regs_init;  -- state registers
  signal N_REGS : regs_type;          -- don't init (vivado fix for fsm infer)

  -- only internal regs have names, only 3 LSB in constant
  constant rbaddr_cntl:  slv3 := "000";  --  0    -/-/f
  constant rbaddr_stat:  slv3 := "001";  --  1    r/w/-
  constant rbaddr_almh:  slv3 := "010";  --  2    r/w/-
  constant rbaddr_temp:  slv3 := "100";  --  4    r/-/-
  constant rbaddr_alm:   slv3 := "101";  --  5    r/-/-
  constant rbaddr_eos:   slv3 := "111";  --  7    r/-/-

  constant cntl_rbf_reset:    integer :=    15;  

  constant stat_rbf_jlock:    integer :=     3;
  constant stat_rbf_jmod:     integer :=     2;
  constant stat_rbf_jbusy:    integer :=     1;
  constant stat_rbf_ot:       integer :=     0;

begin

  assert DAWIDTH=7 or DAWIDTH=8 
    report "assert(DAWIDTH=7 or DAWIDTH=8): unsupported DAWIDTH"
    severity failure;
  assert ALWIDTH<=16 
    report "assert ALWIDTH<16: unsupported ALWIDTH"
    severity failure;
  assert TEWIDTH=10 or TEWIDTH=12 
    report "assert(TEWIDTH=10 or TEWIDTH=12): unsupported TEWIDTH"
    severity failure;
  assert IBASE(2 downto 0) = "000"
    report "assert IBASE(2:0) = 000: invalid IBASE"
    severity failure;

  proc_regs: process (CLK)
  begin

    if rising_edge(CLK) then
      if RESET = '1' then
        R_REGS <= regs_init;
      else
        R_REGS <= N_REGS;
      end if;
    end if;

  end process proc_regs;
  
  proc_next: process (R_REGS, RB_MREQ, SM_DO, SM_DRDY, SM_EOS, SM_ALM, SM_OT,
                      SM_JTAGLOCKED, SM_JTAGMODIFIED, SM_JTAGBUSY)

    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;

    variable irb_ack  : slbit := '0';
    variable irb_busy : slbit := '0';
    variable irb_err  : slbit := '0';
    variable irb_dout : slv16 := (others=>'0');
    variable irbena   : slbit := '0';

    variable irb_addr_ext : slbit := '0';
    variable irb_addr_int : slbit := '0';

    variable ism_den   : slbit := '0';
    variable ism_dwe   : slbit := '0';
    variable ism_daddr : slv(DAWIDTH-1 downto 0)  := (others=>'0');
    variable ism_reset : slbit := '0';

  begin

    r := R_REGS;
    n := R_REGS;

    irb_ack  := '0';
    irb_busy := '0';
    irb_err  := '0';
    irb_dout := (others=>'0');

    irbena  := RB_MREQ.re or RB_MREQ.we;

    -- check for internal rbus controller register window
    irb_addr_int := '0';
    if RB_MREQ.addr(DAWIDTH-1 downto 3) = IBASE(DAWIDTH-1 downto 3) then
      irb_addr_int := '1';      
    end if;
    
    ism_den   := '0';
    ism_dwe   := '0';
    ism_daddr := RB_MREQ.addr(DAWIDTH-1 downto 0); -- default 
    ism_reset := '0';
    
    -- handle EOS
    if SM_EOS = '1' then
      n.tpend := '1';                   -- queue temp read
      n.eoscnt := slv(unsigned(r.eoscnt) + 1); -- and count it
    end if;

    -- update stat and almh register fields
    n.stat_ot    := r.stat_ot    or SM_OT;
    n.stat_jlock := r.stat_jlock or SM_JTAGLOCKED;
    n.stat_jmod  := r.stat_jmod  or SM_JTAGMODIFIED;
    n.stat_jbusy := r.stat_jbusy or SM_JTAGBUSY;
    n.almh       := r.almh       or SM_ALM;
    
    -- rbus address decoder
    n.rbsel := '0';
    if RB_MREQ.aval='1' and RB_MREQ.addr(15 downto 7)=RB_ADDR(15 downto 7) then
      n.rbsel := '1';
    end if;
    
    irb_ack  := r.rbsel and irbena;     -- ack all accesses
    irb_busy := irb_ack;                -- busy is default 
    
    -- internal state machine
    case r.state is
      when s_init =>                    -- init: wait for jtaglocked down ----
        if SM_JTAGLOCKED = '0' then
          n.stat_jlock := '0';            -- clear status
          n.state := s_idle;              -- start working
        end if;
        
      when s_idle =>                    -- idle: dispatch --------------------
        if r.tpend = '1' then             -- temp update pending ?
          n.tpend   := '0';                 -- mark done
          if SM_JTAGLOCKED = '0' then       -- if not jlocked
            ism_daddr := "0000000";           -- temp is reg 00h
            ism_dwe   := '0';                 -- do read
            ism_den   := '1';                 -- start drp cycle
            n.state   := s_twait;
          end if;
          
        elsif r.rbsel = '1' then          -- rbus access ?
          if irb_addr_int ='1' then         -- internal controller regs
            irb_busy := '0';
            case RB_MREQ.addr(2 downto 0)  is
              when rbaddr_cntl  =>
                if RB_MREQ.we = '1' then
                  ism_reset := RB_MREQ.din(cntl_rbf_reset);
                end if;

              when rbaddr_stat =>
                if RB_MREQ.we = '1' then
                  n.stat_jlock := r.stat_jlock and
                                    not RB_MREQ.din(stat_rbf_jlock);
                  n.stat_jmod  := r.stat_jmod  and
                                    not RB_MREQ.din(stat_rbf_jmod);
                  n.stat_jbusy := r.stat_jbusy and
                                    not RB_MREQ.din(stat_rbf_jbusy);
                  n.stat_ot    := r.stat_ot    and
                                    not RB_MREQ.din(stat_rbf_ot);
                end if;

              when rbaddr_almh =>
                if RB_MREQ.we = '1' then
                  n.almh  := r.almh and not RB_MREQ.din(r.almh'range);
                end if;

              when rbaddr_temp =>                
                irb_err  := RB_MREQ.we;
              when rbaddr_alm  =>
                irb_err  := RB_MREQ.we;
              when rbaddr_eos  =>
                irb_err  := RB_MREQ.we;

              when others =>
                irb_err  := irbena;
            end case;
            
          else                              -- sysmon reg access 
            if irbena = '1' then
              if SM_JTAGLOCKED = '0' then       -- if not jlocked
                ism_daddr := RB_MREQ.addr(ism_daddr'range);
                ism_dwe   := RB_MREQ.we;
                ism_den   := '1';               -- start drp cycle
                n.state   := s_wait;
              else
                irb_err  := '1';                -- quit with error if jlocked
              end if;
            end if;

          end if;
        end if;

      when s_wait =>                    -- wait: wait on drdy ----------------
        n.state := s_wait;
        if SM_DRDY = '1' then
          irb_busy := '0';
          n.state := s_idle;
        end if;
        
      when s_twait =>                   -- twait: wait on drdy of temp read --
        n.state := s_twait;
        if SM_DRDY = '1' then
          n.temp := SM_DO(15 downto 16-TEWIDTH); -- take msb's
          n.state := s_idle;
        end if;
        
      when others => null;                -- <> ------------------------------
    end case;  -- case r.state

    -- rbus output driver
    if r.rbsel = '1' then
      if irb_addr_int = '1' then
        case RB_MREQ.addr(2 downto 0)  is
          when rbaddr_stat =>
            irb_dout(stat_rbf_jlock) := r.stat_jlock;
            irb_dout(stat_rbf_jmod)  := r.stat_jmod;
            irb_dout(stat_rbf_jbusy) := r.stat_jbusy;
            irb_dout(stat_rbf_ot)    := r.stat_ot;

          when rbaddr_almh  =>
            irb_dout(r.almh'range) := r.almh;

          when rbaddr_temp  =>
            irb_dout(r.temp'range) := r.temp;

          when rbaddr_alm =>
            irb_dout(SM_ALM'range) := SM_ALM;

          when rbaddr_eos =>
            irb_dout := r.eoscnt;

          when others => 
            irb_dout := (others=>'0');            
        end case;
      else
        irb_dout := SM_DO;
      end if;
    end if;

    N_REGS    <= n;

    SM_DEN    <= ism_den;
    SM_DWE    <= ism_dwe;
    SM_DADDR  <= ism_daddr;
    SM_DI     <= RB_MREQ.din;
    SM_RESET  <= ism_reset;

    TEMP  <= r.temp;    

    RB_SRES      <= rb_sres_init;
    RB_SRES.ack  <= irb_ack;
    RB_SRES.busy <= irb_busy;
    RB_SRES.err  <= irb_err;
    RB_SRES.dout <= irb_dout;

  end process proc_next;

end syn;
