-- $Id: pdp11_dmhbpt_unit.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2015-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    pdp11_dmhbpt_unit - syn
-- Description:    pdp11: dmhbpt - individual unit
--
-- Dependencies:   -
-- Test bench:     -
--
-- Target Devices: generic
-- Tool versions:  ise 14.7; viv 2014.4-2019.1; ghdl 0.31-0.35
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2015-07-12   700 14.7  131013 xc6slx16-2    39   67    0   21 s  3.8
--
-- Revision History: -
-- Date         Rev Version  Comment
-- 2019-06-02  1159   1.0.1  use rbaddr_ constants
-- 2015-07-19   702   1.0    Initial version
-- 2015-07-05   698   0.1    First draft
------------------------------------------------------------------------------
--
-- rbus registers:
--
--  Addr   Bits  Name        r/w/f  Function
--    00         cntl        r/w/-  Control register
--        05:04    mode      r/w/-    mode select (k=00,s=01,u=11; 10->all)
--           02    irena     r/w/-    enable instruction read bpt
--           01    dwena     r/w/-    enable data write bpt
--           00    drena     r/w/-    enable data read  bpt
--    01         stat        r/w/-  Status register
--           01    dwseen    r/w/-    dw bpt seen
--           02    irseen    r/w/-    ir bpt seen
--           00    drseen    r/w/-    dr bpt seen
--    10  15:01  hilim       r/w/-  upper address limit, inclusive (def: 000000)
--    11  15:01  lolim       r/w/-  lower address limit, inclusive (def: 000000)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.rblib.all;
use work.pdp11.all;

-- ----------------------------------------------------------------------------

entity pdp11_dmhbpt_unit is             -- dmhbpt - indivitial unit
  generic (
    RB_ADDR : slv16 := rbaddr_dmhbpt_off;
    INDEX : natural := 0);
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : out rb_sres_type;         -- rbus: response
    DM_STAT_SE : in dm_stat_se_type;    -- debug and monitor status - sequencer
    DM_STAT_DP : in dm_stat_dp_type;    -- debug and monitor status - data path
    DM_STAT_VM : in dm_stat_vm_type;    -- debug and monitor status - vmbox
    DM_STAT_CO : in dm_stat_co_type;    -- debug and monitor status - core
    HBPT : out slbit                    -- hw break flag
  );
end pdp11_dmhbpt_unit;


architecture syn of pdp11_dmhbpt_unit is

  constant rbaddr_cntl  : slv2 := "00";  -- cntl  address offset
  constant rbaddr_stat  : slv2 := "01";  -- stat  address offset
  constant rbaddr_hilim : slv2 := "10";  -- hilim address offset
  constant rbaddr_lolim : slv2 := "11";  -- lolim address offset
  
  subtype  cntl_rbf_mode    is integer range  5 downto  4;
  constant cntl_rbf_irena    : integer :=     2;
  constant cntl_rbf_dwena    : integer :=     1;
  constant cntl_rbf_drena    : integer :=     0;

  constant stat_rbf_irseen   : integer :=     2;
  constant stat_rbf_dwseen   : integer :=     1;
  constant stat_rbf_drseen   : integer :=     0;

  -- the mode 10 is used a wildcard, cpu only uses 00 (k) 01 (s) and 11 (u)
  constant cntl_mode_all     : slv2 := "10";

  subtype  lim_rbf          is integer range 15 downto  1;

  type regs_type is record
    rbsel  : slbit;                     -- rbus select
    mode   : slv2;                      -- mode select
    irena  : slbit;                     -- ir enable
    dwena  : slbit;                     -- dw enable
    drena  : slbit;                     -- dr enable
    irseen : slbit;                     -- ir seen
    dwseen : slbit;                     -- dw seen
    drseen : slbit;                     -- dr seen
    hilim  : slv16_1;                   -- hilim
    lolim  : slv16_1;                   -- lolim
  end record regs_type;
  
  constant regs_init : regs_type := (
    '0',                                -- rbsel
    "00",                               -- mode
    '0','0','0',                        -- *ena
    '0','0','0',                        -- *seen
    (others=>'0'),                      -- hilim
    (others=>'0')                       -- lolim
  );

  signal R_REGS : regs_type := regs_init;  -- state registers
  signal N_REGS : regs_type := regs_init;  -- next value state regs

  begin

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

  proc_next: process (R_REGS, RB_MREQ, DM_STAT_SE, DM_STAT_DP,
                      DM_STAT_VM, DM_STAT_VM.vmcntl,    -- xst needs sub-records
                      DM_STAT_CO)

    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;
    variable irb_ack  : slbit := '0';
    variable irb_err  : slbit := '0';   -- FIXME: needed ??
    variable irb_busy : slbit := '0';   -- FIXME: needed ??
    variable irb_dout : slv16 := (others=>'0');
    variable irbena  : slbit := '0';
    variable ihbpt   : slbit := '0';

  begin

    r := R_REGS;
    n := R_REGS;

    irb_ack  := '0';
    irb_err  := '0';
    irb_busy := '0';
    irb_dout := (others=>'0');
    irbena  := RB_MREQ.re or RB_MREQ.we;        

    -- rbus address decoder
    n.rbsel := '0';
    if RB_MREQ.aval='1' and                                -- address valid
      RB_MREQ.addr(12 downto 4)=RB_ADDR(12 downto 4) and   -- block address
      RB_MREQ.addr( 3 downto 2)=slv(to_unsigned(INDEX,2))  -- unit  address
    then
      n.rbsel := '1';
    end if;

    -- rbus transactions
    if r.rbsel = '1' then
      irb_ack := irbena;                -- ack all accesses
      case RB_MREQ.addr(1 downto 0) is
        when rbaddr_cntl =>                 -- cntl ------------------
         if RB_MREQ.we = '1' then 
            n.mode   := RB_MREQ.din(cntl_rbf_mode);
            n.irena  := RB_MREQ.din(cntl_rbf_irena);
            n.dwena  := RB_MREQ.din(cntl_rbf_dwena);
            n.drena  := RB_MREQ.din(cntl_rbf_drena);
         end if;

        when rbaddr_stat =>                 -- stat ------------------
         if RB_MREQ.we = '1' then 
            n.irseen := RB_MREQ.din(stat_rbf_irseen);
            n.dwseen := RB_MREQ.din(stat_rbf_dwseen);
            n.drseen := RB_MREQ.din(stat_rbf_drseen);
         end if;

        when rbaddr_hilim =>                -- hilim -----------------
          if RB_MREQ.we = '1' then
            n.hilim := RB_MREQ.din(lim_rbf);
          end if;

        when rbaddr_lolim =>                -- lolim -----------------
          if RB_MREQ.we = '1' then
            n.lolim := RB_MREQ.din(lim_rbf);
          end if;

        when others => null;                -- <> --------------------          
      end case;
    end if;

    -- rbus output driver
    if r.rbsel = '1' then
      case RB_MREQ.addr(1 downto 0) is
        when rbaddr_cntl =>                 -- cntl ------------------
          irb_dout(cntl_rbf_mode)   := r.mode;
          irb_dout(cntl_rbf_irena)  := r.irena;
          irb_dout(cntl_rbf_dwena)  := r.dwena;
          irb_dout(cntl_rbf_drena)  := r.drena;
        when rbaddr_stat =>                 -- stat ------------------
          irb_dout(stat_rbf_irseen) := r.irseen;
          irb_dout(stat_rbf_dwseen) := r.dwseen;
          irb_dout(stat_rbf_drseen) := r.drseen;
        when rbaddr_hilim =>                -- hilim -----------------
          irb_dout(lim_rbf) := r.hilim;
        when rbaddr_lolim =>                -- lolim -----------------
          irb_dout(lim_rbf) := r.lolim;
        when others => null;
      end case;
    end if;

    -- breakpoint unit logic
    ihbpt := '0';
    if DM_STAT_VM.vmcntl.req  = '1' and
       DM_STAT_VM.vmcntl.cacc = '0' and
       (DM_STAT_VM.vmcntl.mode = r.mode or r.mode = cntl_mode_all )and
       unsigned(DM_STAT_VM.vmaddr(lim_rbf))>=unsigned(r.lolim) and
       unsigned(DM_STAT_VM.vmaddr(lim_rbf))<=unsigned(r.hilim) then

      if r.irena = '1' then
        if DM_STAT_SE.istart = '1' and      -- only for instruction fetches !
           DM_STAT_VM.vmcntl.dspace = '0' and
           DM_STAT_VM.vmcntl.wacc   = '0' then
          ihbpt    := '1';
          n.irseen := '1';
        end if;
      end if;

      if r.dwena = '1' then
        if DM_STAT_VM.vmcntl.dspace = '1' and
           DM_STAT_VM.vmcntl.wacc   = '1' then
          ihbpt    := '1';
          n.dwseen := '1';
        end if;
      end if;

      if r.drena = '1' then
        if DM_STAT_VM.vmcntl.dspace = '1' and
           DM_STAT_VM.vmcntl.wacc   = '0' then
          ihbpt    := '1';
          n.drseen := '1';
        end if;
      end if;

    end if;
    
    N_REGS <= n;

    HBPT   <= ihbpt;
    
    RB_SRES.ack  <= irb_ack;
    RB_SRES.err  <= irb_err;
    RB_SRES.busy <= irb_busy;
    RB_SRES.dout <= irb_dout;

  end process proc_next;

end syn;
