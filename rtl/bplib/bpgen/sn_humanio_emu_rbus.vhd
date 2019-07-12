-- $Id: sn_humanio_emu_rbus.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2017-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    sn_humanio_emu_rbus - syn
-- Description:    sn_humanio rbus emulator
--
-- Dependencies:   -
--
-- Test bench:     -
--
-- Target Devices: generic
-- Tool versions:  viv 2017.1-2019,1; ghdl 0.34-0.35
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2017-06-11   912   1.0    Initial version (derived from sn_humanio_rbus
------------------------------------------------------------------------------
--
-- rbus registers:
--
-- Addr   Bits  Name        r/w/f  Function
--  000         stat        r/-/-  Status register
--           15   emu       r/-/-    emulation (always 1)
--        14:12   hdig      r/-/-    display size as (2**DCWIDTH)-1
--        11:08   hled      r/-/-    led     size as LWIDTH-1
--         7:04   hbtn      r/-/-    button  size as BWIDTH-1
--         3:00   hswi      r/-/-    switch  size as SWIDTH-1
--         
--  001         cntl        r/w/-  Control register
--            4   dsp1_en   r/-/-    always 0
--            3   dsp0_en   r/-/-    always 0
--            2   dp_en     r/-/-    always 0
--            1   led_en    r/-/-    always 0
--            0   swi_en    r/-/-    always 1: SWI will be driven by rbus
--            
--  010    x:00 btn         -/-/f    w: will pulse BTN
--  011    x:00 swi         r/w/-    SWI status
--  100    x:00 led         r/-/-    LED status
--  101    x:00 dp          r/-/-    DSP_DP status
--  110   15:00 dsp0        r/-/-    DSP_DAT lsb status
--  111   15:00 dsp1        r/-/-    DSP_DAT msb status
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.rblib.all;

-- ----------------------------------------------------------------------------

entity sn_humanio_emu_rbus is           -- sn_humanio rbus emulator
  generic (
    SWIDTH : positive := 8;             -- SWI port width
    BWIDTH : positive := 4;             -- BTN port width
    LWIDTH : positive := 8;             -- LED port width
    DCWIDTH : positive := 2;            -- digit counter width (2 or 3)
    RB_ADDR : slv16 := x"fef0");
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit := '0';            -- reset
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : out rb_sres_type;         -- rbus: response
    SWI : out slv(SWIDTH-1 downto 0);   -- switch settings
    BTN : out slv(BWIDTH-1 downto 0);   -- button settings
    LED : in slv(LWIDTH-1 downto 0);    -- led data
    DSP_DAT : in slv(4*(2**DCWIDTH)-1 downto 0);   -- display data
    DSP_DP : in slv((2**DCWIDTH)-1 downto 0)       -- display decimal points
  );
end sn_humanio_emu_rbus;

architecture syn of sn_humanio_emu_rbus is
  
  type regs_type is record
    rbsel : slbit;                      -- rbus select
    swi : slv(SWIDTH-1 downto 0);       -- rbus swi
    btn : slv(BWIDTH-1 downto 0);       -- rbus btn
    led : slv(LWIDTH-1 downto 0);        -- hio led
    dsp_dat : slv(4*(2**DCWIDTH)-1 downto 0); -- hio dsp_dat
    dsp_dp  : slv((2**DCWIDTH)-1 downto 0);   -- hio dsp_dp
  end record regs_type;

  constant swizero : slv(SWIDTH-1 downto 0) := (others=>'0');
  constant btnzero : slv(BWIDTH-1 downto 0) := (others=>'0');
  constant ledzero : slv(LWIDTH-1 downto 0) := (others=>'0');
  constant dpzero  : slv((2**DCWIDTH)-1 downto 0) := (others=>'0');
  constant datzero : slv(4*(2**DCWIDTH)-1 downto 0) := (others=>'0');

  constant regs_init : regs_type := (
    '0',                                -- rbsel
    swizero,                            -- swi
    btnzero,                            -- btn
    ledzero,                            -- led
    datzero,                            -- dsp_dat
    dpzero                              -- dsp_dp
  );

  signal R_REGS : regs_type := regs_init;  -- state registers
  signal N_REGS : regs_type := regs_init;  -- next value state regs

  constant stat_rbf_emu:     integer := 15;
  subtype  stat_rbf_hdig     is integer range 14 downto 12;
  subtype  stat_rbf_hled     is integer range 11 downto  8;
  subtype  stat_rbf_hbtn     is integer range  7 downto  4;
  subtype  stat_rbf_hswi     is integer range  3 downto  0;

  constant cntl_rbf_dsp1_en: integer :=  4;
  constant cntl_rbf_dsp0_en: integer :=  3;
  constant cntl_rbf_dp_en:   integer :=  2;
  constant cntl_rbf_led_en:  integer :=  1;
  constant cntl_rbf_swi_en:  integer :=  0;

  constant rbaddr_stat:  slv3 := "000";  --  0    r/-/-
  constant rbaddr_cntl:  slv3 := "001";  --  0    r/w/-
  constant rbaddr_btn:   slv3 := "010";  --  1    -/-/f
  constant rbaddr_swi:   slv3 := "011";  --  1    r/w/-
  constant rbaddr_led:   slv3 := "100";  --  2    r/-/-
  constant rbaddr_dp:    slv3 := "101";  --  3    r/-/-
  constant rbaddr_dsp0:  slv3 := "110";  --  4    r/-/-
  constant rbaddr_dsp1:  slv3 := "111";  --  5    r/-/-

  subtype  dspdat_msb is integer range 4*(2**DCWIDTH)-1 downto 4*(2**DCWIDTH)-16;
  subtype  dspdat_lsb is integer range 15 downto 0;
  
begin

  assert SWIDTH<=16 
    report "assert (SWIDTH<=16)"
    severity failure;
  assert BWIDTH<=8
    report "assert (BWIDTH<=8)"
    severity failure;
  assert LWIDTH<=16
    report "assert (LWIDTH<=16)"
    severity failure;

  assert DCWIDTH=2 or DCWIDTH=3
  report "assert(DCWIDTH=2 or DCWIDTH=3): unsupported DCWIDTH"
  severity FAILURE;

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
  
  proc_next: process (R_REGS, RB_MREQ, LED, DSP_DAT, DSP_DP)

    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;

    variable irb_ack  : slbit := '0';
    variable irb_busy : slbit := '0';
    variable irb_err  : slbit := '0';
    variable irb_dout : slv16 := (others=>'0');
    variable irbena   : slbit := '0';
    
  begin

    r := R_REGS;
    n := R_REGS;

    irb_ack  := '0';
    irb_busy := '0';
    irb_err  := '0';
    irb_dout := (others=>'0');

    irbena  := RB_MREQ.re or RB_MREQ.we;

    -- input registers
    n.led     := LED;
    n.dsp_dat := DSP_DAT;
    n.dsp_dp  := DSP_DP;
    -- clear btn register --> cause single cycle pulses
    n.btn  := (others=>'0');

    -- rbus address decoder
    n.rbsel := '0';
    if RB_MREQ.aval='1' and RB_MREQ.addr(15 downto 3)=RB_ADDR(15 downto 3) then
      n.rbsel := '1';
    end if;

    -- rbus transactions
    if r.rbsel = '1' then
      irb_ack := irbena;                  -- ack all accesses

      case RB_MREQ.addr(2 downto 0) is
        
        when rbaddr_stat =>
          irb_dout(stat_rbf_emu)   := '1';
          irb_dout(stat_rbf_hdig)  := slv(to_unsigned((2**DCWIDTH)-1,3));
          irb_dout(stat_rbf_hled)  := slv(to_unsigned(LWIDTH-1,4));
          irb_dout(stat_rbf_hbtn)  := slv(to_unsigned(BWIDTH-1,4));
          irb_dout(stat_rbf_hswi)  := slv(to_unsigned(SWIDTH-1,4));
          if RB_MREQ.we = '1' then
            irb_ack := '0';
          end if;
          
        when rbaddr_cntl =>
          irb_dout(cntl_rbf_dsp1_en) := '0';
          irb_dout(cntl_rbf_dsp0_en) := '0';
          irb_dout(cntl_rbf_dp_en)   := '0';
          irb_dout(cntl_rbf_led_en)  := '0';
          irb_dout(cntl_rbf_swi_en)  := '1';
          
        when rbaddr_btn =>
          irb_dout(r.btn'range) := r.btn;
          if RB_MREQ.we = '1' then
            n.btn    := RB_MREQ.din(n.btn'range);
          end if;
          
        when rbaddr_swi =>
          irb_dout(r.swi'range) := r.swi;
          if RB_MREQ.we = '1' then
            n.swi := RB_MREQ.din(n.swi'range);
          end if;
          
        when rbaddr_led =>
          irb_dout(r.led'range) := r.led;
          
        when rbaddr_dp =>
          irb_dout(r.dsp_dp'range) := r.dsp_dp;
          
        when rbaddr_dsp0 =>
          irb_dout := r.dsp_dat(dspdat_lsb);

        when rbaddr_dsp1 =>
          irb_dout := r.dsp_dat(dspdat_msb);

        when others => null;          
      end case;

    end if;
    
    N_REGS       <= n;

    BTN          <= R_REGS.btn;
    SWI          <= R_REGS.swi;
  
    RB_SRES      <= rb_sres_init;
    RB_SRES.ack  <= irb_ack;
    RB_SRES.busy <= irb_busy;
    RB_SRES.err  <= irb_err;
    RB_SRES.dout <= irb_dout;

  end process proc_next;

end syn;
