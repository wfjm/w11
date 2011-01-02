-- $Id: s3_humanio_rbus.vhd 352 2011-01-02 13:01:37Z mueller $
--
-- Copyright 2010- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    s3_humanio_rbus - syn
-- Description:    s3_humanio with rbus interceptor
--
-- Dependencies:   s3board/s3_humanio
--
-- Test bench:     -
--
-- Target Devices: generic
-- Tool versions:  xst 11.4, 12.1; ghdl 0.26-0.29
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2010-12-29   300 12.1    M53d xc3s1000-4    93  138    0  111 s  6.8 ns 
-- 2010-06-03   300 11.4    L68  xc3s1000-4    92  137    0  111 s  6.7 ns 
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2010-12-29   351   1.1    renamed from s3_humanio_rri; ported to rbv3
-- 2010-06-18   306   1.0.1  rename rbus data fields to _rbf_
-- 2010-06-03   300   1.0    Initial version
------------------------------------------------------------------------------
--
-- rbus registers:
--
-- Address   Bits Name        r/w/f  Function
-- bbbbbb00       cntl        r/w/-  Control register and BTN access
--             11   dat_en    r/w/-    if 1 display data will be driven by rri
--             10   dp_en     r/w/-    if 1 display dp's will be driven by rri
--              9   led_en    r/w/-    if 1 LED will be driven by rri
--              8   swi_en    r/w/-    if 1 SWI will be driven by rri
--           3:00   btn       r/w/-    r: return hio BTN status
--                                     w: BTN is hio BTN ored with this fields
--
-- bbbbbb01  7:00   swi       r/w/-    r: return hio SWI status
--                                     w: will drive SWI when swi_en=1
--
-- bbbbbb10         leddp     r/w/-  Interface to LED and DSP_DP
--          11:09     dsp_dp  r/w/-    r: returns DSP_DP status
--                                     w: will drive display dp's when dp_en=1
--           7:00     led     r/w/-    r: returns LED status
--                                     w: will drive led's when led_en=1
--
-- bbbbbb11 15:00   dsp_dat   r/w/-    r: return hio DSP_DAT status
--                                     w: will drive DSP_DAT when dat_en=1
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

use work.slvtypes.all;
use work.rblib.all;
use work.s3boardlib.all;

-- ----------------------------------------------------------------------------

entity s3_humanio_rbus is               -- human i/o handling /w rbus intercept
  generic (
    DEBOUNCE : boolean := true;         -- instantiate debouncer for SWI,BTN
    RB_ADDR : slv8 := conv_std_logic_vector(2#10000000#,8));
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    CE_MSEC : in slbit;                 -- 1 ms clock enable
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : out rb_sres_type;         -- rbus: response
    SWI : out slv8;                     -- switch settings, debounced
    BTN : out slv4;                     -- button settings, debounced
    LED : in slv8;                      -- led data
    DSP_DAT : in slv16;                 -- display data
    DSP_DP : in slv4;                   -- display decimal points
    I_SWI : in slv8;                    -- pad-i: switches
    I_BTN : in slv4;                    -- pad-i: buttons
    O_LED : out slv8;                   -- pad-o: leds
    O_ANO_N : out slv4;                 -- pad-o: 7 seg disp: anodes   (act.low)
    O_SEG_N : out slv8                  -- pad-o: 7 seg disp: segments (act.low)
  );
end s3_humanio_rbus;

architecture syn of s3_humanio_rbus is
  
  type regs_type is record
    rbsel : slbit;                      -- rbus select
    swi : slv8;                         -- rbus swi
    btn : slv4;                         -- rbus btn
    led : slv8;                         -- rbus led
    dsp_dat : slv16;                    -- rbus dsp_dat
    dsp_dp  : slv4;                     -- rbus dsp_dp
    swi_en : slbit;                     -- enable: swi from rri
    led_en : slbit;                     -- enable: led from rri
    dat_en : slbit;                     -- enable: dsp_dat from rri
    dp_en : slbit;                      -- enable: dsp_dp  from rri
  end record regs_type;
  
  constant regs_init : regs_type := (
    '0',                                -- rbsel
    (others=>'0'),                      -- swi
    (others=>'0'),                      -- btn
    (others=>'0'),                      -- led
    (others=>'0'),                      -- dsp_dat
    (others=>'0'),                      -- dsp_dp
    '0','0','0','0'                     -- (swi|led|dat|dp)_en
  );

  signal R_REGS : regs_type := regs_init;  -- state registers
  signal N_REGS : regs_type := regs_init;  -- next value state regs

  constant cntl_rbf_dat_en:  integer := 11;
  constant cntl_rbf_dp_en:   integer := 10;
  constant cntl_rbf_led_en:  integer :=  9;
  constant cntl_rbf_swi_en:  integer :=  8;
  subtype  cntl_rbf_btn      is integer range  3 downto  0;
  subtype  leddp_rbf_dsp_dp  is integer range 11 downto  8;
  subtype  leddp_rbf_led     is integer range  7 downto  0;

  constant rbaddr_cntl:  slv2 := "00";  --  0    -/r/w
  constant rbaddr_swi:   slv2 := "01";  --  1    -/r/w
  constant rbaddr_leddp: slv2 := "10";  --  2    -/r/w
  constant rbaddr_dsp:   slv2 := "11";  --  3    -/r/w

  signal HIO_SWI : slv8 := (others=>'0');
  signal HIO_BTN : slv4 := (others=>'0');
  signal HIO_LED : slv8 := (others=>'0');
  signal HIO_DSP_DAT : slv16 := (others=>'0');
  signal HIO_DSP_DP  : slv4 := (others=>'0');

begin

  HIO : s3_humanio
    generic map (
      DEBOUNCE => DEBOUNCE)
    port map (
      CLK     => CLK,
      RESET   => RESET,
      CE_MSEC => CE_MSEC,
      SWI     => HIO_SWI,                   
      BTN     => HIO_BTN,                   
      LED     => HIO_LED,                   
      DSP_DAT => HIO_DSP_DAT,               
      DSP_DP  => HIO_DSP_DP,
      I_SWI   => I_SWI,                 
      I_BTN   => I_BTN,
      O_LED   => O_LED,
      O_ANO_N => O_ANO_N,
      O_SEG_N => O_SEG_N
    );
  
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
  
  proc_next: process (R_REGS, RB_MREQ, LED, DSP_DAT, DSP_DP,
                      HIO_SWI, HIO_BTN, HIO_LED, HIO_DSP_DAT, HIO_DSP_DP)

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

    -- rbus address decoder
    n.rbsel := '0';
    if RB_MREQ.aval='1' and RB_MREQ.addr(7 downto 2)=RB_ADDR(7 downto 2) then
      n.rbsel := '1';
    end if;

    -- rbus transactions
    if r.rbsel = '1' then
      irb_ack := irbena;                  -- ack all accesses

      case RB_MREQ.addr(1 downto 0) is

        when rbaddr_cntl =>
          irb_dout(cntl_rbf_dat_en) := r.dat_en;
          irb_dout(cntl_rbf_dp_en)  := r.dp_en;
          irb_dout(cntl_rbf_led_en) := r.led_en;
          irb_dout(cntl_rbf_swi_en) := r.swi_en;
          irb_dout(cntl_rbf_btn)    := HIO_BTN;
          if RB_MREQ.we = '1' then
            n.dat_en := RB_MREQ.din(cntl_rbf_dat_en);
            n.dp_en  := RB_MREQ.din(cntl_rbf_dp_en);
            n.led_en := RB_MREQ.din(cntl_rbf_led_en);
            n.swi_en := RB_MREQ.din(cntl_rbf_swi_en);
            n.btn    := RB_MREQ.din(cntl_rbf_btn);
          end if;
          
        when rbaddr_swi =>
          irb_dout(HIO_SWI'range) := HIO_SWI;
          if RB_MREQ.we = '1' then
            n.swi := RB_MREQ.din(n.swi'range);
          end if;
          
        when rbaddr_leddp =>
          irb_dout(leddp_rbf_dsp_dp) := HIO_DSP_DP;
          irb_dout(leddp_rbf_led)    := HIO_LED;
          if RB_MREQ.we = '1' then
            n.dsp_dp := RB_MREQ.din(leddp_rbf_dsp_dp);
            n.led    := RB_MREQ.din(leddp_rbf_led);
          end if;
          
        when rbaddr_dsp =>
          irb_dout := HIO_DSP_DAT;
          if RB_MREQ.we = '1' then
            n.dsp_dat := RB_MREQ.din;
          end if;

        when others => null;
      end case;

    end if;

    BTN <= HIO_BTN or r.btn;
    
    if r.swi_en = '0' then
      SWI <= HIO_SWI;
    else
      SWI <= r.swi;
    end if;

    if r.led_en = '0' then
      HIO_LED <= LED;
    else
      HIO_LED <= r.led;
    end if;
    
    if r.dp_en = '0' then
      HIO_DSP_DP  <= DSP_DP;
    else
      HIO_DSP_DP  <= r.dsp_dp;
    end if;
    
    if r.dat_en = '0' then
      HIO_DSP_DAT <= DSP_DAT;
    else
      HIO_DSP_DAT <= r.dsp_dat;
    end if;
    
    N_REGS       <= n;

    RB_SRES      <= rb_sres_init;
    RB_SRES.ack  <= irb_ack;
    RB_SRES.busy <= irb_busy;
    RB_SRES.err  <= irb_err;
    RB_SRES.dout <= irb_dout;

  end process proc_next;

end syn;
