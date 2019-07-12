-- $Id: mt45w8mw16b.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2010-2016 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
-- 
------------------------------------------------------------------------------
-- Module Name:    mt45w8mw16b - sim
-- Description:    Micron MT45W8MW16B CellularRAM model
--                 Currently a much simplified model
--                 - only async accesses
--                 - ignores CLK 
--                 - simple model for response of DATA lines, but no
--                   check for timing violations of control lines
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  xst 11.4-14.7; ghdl 0.26-0.33
-- Revision History: 
-- Date         Rev Version  Comment
-- 2016-08-18   799   1.4.1  remove 'assert false' from report statements
-- 2016-07-10   786   1.4    add RCR handling; page mode by default now off !!
-- 2015-12-26   718   1.3.3  BUGFIX: initialize L_ADDR with all '1', see comment
-- 2011-11-19   427   1.3.2  now numeric_std clean
-- 2010-06-03   299   1.3.1  improved timing model (WE cycle, robust T_apa)
-- 2010-06-03   298   1.3    add timing model again
-- 2010-05-28   295   1.2    drop timing (was incorrect), pure functional now
-- 2010-05-21   293   1.1    add BCR (only read of default so far)
-- 2010-05-16   291   1.0    Initial version (inspired by is61lv25616al)
------------------------------------------------------------------------------
-- Truth table accoring to data sheet:
--  
-- Asynchronous Mode (BCR(15)=1)
--   Operation               CLK ADV_N CE_N OE_N WE_N CRE xB_N WT  DATA
--   Read                     L     L    L    L    H   L    L  act data-out
--   Write                    L     L    L    X    L   L    L  act data-in
--   Standby                  L     X    H    X    X   L    X  'z' 'z'
--   CRE write                L     L    L    H    L   H    X  act 'z'
--   CRE read                 L     L    L    L    H   H    L  act conf-out
--
-- Burst Mode (BCR(15)=0)
--   Operation               CLK ADV_N CE_N OE_N WE_N CRE xB_N WT  DATA
--   Async read               L     L    L    L    H   L    L  act data-out
--   Async write              L     L    L    X    L   L    L  act data-in 
--   Standby                  L     X    H    X    X   L    X  'z' 'z'
--   Initial burst read      0-1    L    L    X    H   L    L  act  X
--   Initial burst write     0-1    L    L    H    L   L    X  act  X
--   Burst continue          0-1    H    L    X    X   X    X  act data-in/out
--   CRE write               0-1    L    L    H    L   H    X  act 'z'
--   CRE read                0-1    L    L    L    H   H    L  act conf-out
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;

entity mt45w8mw16b is                   -- Micron MT45W8MW16B CellularRAM model
  port (
    CLK : in slbit;                     -- clock for synchonous operation
    CE_N : in slbit;                    -- chip enable        (act.low)
    OE_N : in slbit;                    -- output enable      (act.low)
    WE_N : in slbit;                    -- write enable       (act.low)
    UB_N : in slbit;                    -- upper byte enable  (act.low)
    LB_N : in slbit;                    -- lower byte enable  (act.low)
    ADV_N : in slbit;                   -- address valid      (act.low)
    CRE : in slbit;                     -- control register enable
    MWAIT : out slbit;                  -- wait (for burst read/write)
    ADDR : in slv23;                    -- address lines
    DATA : inout slv16                  -- data lines
  );
end mt45w8mw16b;


architecture sim of mt45w8mw16b is

  -- timing constants for -701 speed grade (70 ns; 104 MHz)
  constant T_aa   : Delay_length := 70 ns; -- address access time           (max)
  constant T_apa  : Delay_length := 20 ns; -- page access time              (max)
  constant T_oh   : Delay_length :=  5 ns; -- output hold from addr change  (max)
  constant T_oe   : Delay_length := 20 ns; -- output enable to valid output (max)
  constant T_ohz  : Delay_length :=  8 ns; -- output disable to high-z out  (max)
  constant T_olz  : Delay_length :=  3 ns; -- output enable to low-z output (min)
  constant T_lz   : Delay_length := 10 ns; -- chip enable to low-z output   (min)
  constant T_hz   : Delay_length :=  8 ns; -- chip disable to high-z output (max)

  constant memsize : positive := 2**(ADDR'length);
  constant datzero : slv(DATA'range) := (others=>'0');
  type ram_type is array (0 to memsize-1) of slv(DATA'range);

  subtype  xcr_f_sel   is integer range 19 downto 18; -- cre register select
  constant xcr_sel_rcr : slv2 := "00";
  constant xcr_sel_bcr : slv2 := "10";
  
  constant bcr_f_mode   : integer := 15;              -- operating mode 
  constant bcr_f_ilat   : integer := 14;              -- initial latency
  subtype  bcr_f_lc    is integer range 13 downto 11; -- latency counter
  constant bcr_f_wp     : integer := 10;              -- wait polarity
  constant bcr_f_wc     : integer :=  8;              -- wait configuration
  subtype  bcr_f_drive is integer range  5 downto  4; -- drive strength
  constant bcr_f_bw     : integer :=  3;              -- burst wrap
  subtype  bcr_f_bl    is integer range  2 downto  0; -- burst length

  subtype  rcr_f_res3  is integer range 22 downto 20; -- reserved - MBZ
  subtype  rcr_f_res2  is integer range 17 downto  8; -- reserved - MBZ
  constant rcr_f_pmode  : integer :=  7;              -- page mode (1=ena)
  subtype  rcr_f_res1  is integer range  6 downto  5; -- reserved - MBZ
  constant rcr_f_dpd    : integer :=  4;              -- dpd mode  (1=dis)
  constant rcr_f_res0   : integer :=  3;              -- reserved - MBZ
  subtype  rcr_f_par   is integer range  2 downto  0; -- array conf (000=all)
    
  subtype  f_byte1       is integer range 15 downto 8;
  subtype  f_byte0       is integer range  7 downto 0;

  signal CE : slbit := '0';
  signal OE : slbit := '0';
  signal WE : slbit := '0';
  signal BE_L : slbit := '0';
  signal BE_U : slbit := '0';
  signal ADV : slbit := '0';
  signal WE_L_EFF : slbit := '0';
  signal WE_U_EFF : slbit := '0';
  signal WE_C_EFF : slbit := '0';

  signal R_BCR_MODE  : slbit := '1';    -- mode: def: async
  signal R_BCR_ILAT  : slbit := '0';    -- ilat: def: variable
  signal R_BCR_LC    : slv3  := "011";  -- lc:   def: code 3
  signal R_BCR_WP    : slbit := '1';    -- wp:   def: active high
  signal R_BCR_WC    : slbit := '1';    -- wc:   def: assert one before
  signal R_BCR_DRIVE : slv2  := "01";   -- drive:def: 1/2
  signal R_BCR_BW    : slbit := '1';    -- bw:   def: no wrap
  signal R_BCR_BL    : slv3  := "111";  -- bl:   def: continuous

  signal R_RCR_PMODE : slbit := '0';    -- pmode:def: disabled (ena=1 !)
  signal R_RCR_DPD   : slbit := '1';    -- dpd:  def: disabled (ena=0 !)
  signal R_RCR_PAR   : slv3  := "000";  -- par:  def: full array
  signal R_T_APA_EFF : Delay_length  := T_aa;   -- page mode disabled by default

  signal L_ADDR : slv23 := (others=>'1'); -- all '1' for propper 1st access
  signal DOUT_VAL_EN : slbit := '0';
  signal DOUT_VAL_AA : slbit := '0';
  signal DOUT_VAL_PA : slbit := '0';
  signal DOUT_VAL_OE : slbit := '0';
  signal DOUT_LZ_CE  : slbit := '0';
  signal DOUT_LZ_OE  : slbit := '0';

  signal OEWE : slbit := '0';
  signal DOUT : slv16 := (others=>'0');
begin

  CE   <= not CE_N;
  OE   <= not OE_N;
  WE   <= not WE_N;
  BE_L <= not LB_N;
  BE_U <= not UB_N;
  ADV  <= not ADV_N;

  WE_L_EFF <= CE and WE and BE_L and (not CRE);
  WE_U_EFF <= CE and WE and BE_U and (not CRE);

  WE_C_EFF <= CE and WE and CRE;
  
  -- address valid logic, latch ADDR when ADV true
  proc_adv: process (ADV, ADDR)
  begin
    if ADV = '1' then
      L_ADDR <= ADDR;
    end if;
  end process proc_adv;

  -- Notes:
  --  1. the row change (t_aa) and column change (t_apa) timing depends on the
  --     recognition of address changes and of page changes. To keep the logic
  --     simple L_ADDR and addr_last are initialized with all '1'. This gives
  --     proper behaviour unless the very first access uses the very last
  --     address. In w11a systems, with use only 4 MB, this can't happen, in
  --     most other use cases this is very unlikely.
  
  proc_dout_val: process (CE, OE, WE, BE_L, BE_U, ADV, L_ADDR)
    variable addr_last : slv23 := (others=>'1');-- all '1' for propper 1st access
  begin
    if (CE'event   and CE='1') or
       (BE_L'event and BE_L='1') or
       (BE_U'event and BE_U='1') or
       (WE'event   and WE='0') or
       (ADV'event  and ADV='1') then
      DOUT_VAL_EN <= '0', '1' after T_aa;
    end if;
    if L_ADDR'event then
      DOUT_VAL_PA <= '0', '1' after R_T_APA_EFF;
      if L_ADDR(22 downto 4) /= addr_last(22 downto 4) then
        DOUT_VAL_AA <= '0', '1' after T_aa;
      end if;
      addr_last := L_ADDR;
    end if;
    if rising_edge(OE) then
      DOUT_VAL_OE <= '0', '1' after T_oe;
    end if;
  end process proc_dout_val;

  -- to simplify things assume that OE and (not WE) have same effect on output
  -- drivers. The timing rules are very similar indeed...
  OEWE <= OE and (not WE);
  
  proc_dout_lz: process (CE, OEWE)
  begin
    if (CE'event) then
      if CE = '1' then
        DOUT_LZ_CE <= '1' after T_lz;
      else
        DOUT_LZ_CE <= '0' after T_hz;
      end if;
    end if;
    if (OEwe'event) then
      if OEWE = '1' then
        DOUT_LZ_OE <= '1' after T_olz;
      else
        DOUT_LZ_OE <= '0' after T_ohz;
      end if;
    end if;
  end process proc_dout_lz;
  
  proc_cram: process (WE_L_EFF, WE_U_EFF, L_ADDR, DATA)
    variable ram : ram_type := (others=>datzero);
  begin

    -- end of write cycle
    -- note: to_x01 used below to prevent that 'z' a written into mem.
    if falling_edge(WE_L_EFF) then
      ram(to_integer(unsigned(L_ADDR)))(f_byte0) := to_x01(DATA(f_byte0));
    end if;
    if falling_edge(WE_U_EFF) then
      ram(to_integer(unsigned(L_ADDR)))(f_byte1) := to_x01(DATA(f_byte1));
    end if;

    DOUT <= ram(to_integer(unsigned(L_ADDR)));

  end process proc_cram;

  proc_cr: process (WE_C_EFF, L_ADDR)
  begin
    if falling_edge(WE_C_EFF) then
      case L_ADDR(xcr_f_sel) is

        when xcr_sel_rcr =>
          R_RCR_PMODE <= L_ADDR(rcr_f_pmode);
          if L_ADDR(rcr_f_pmode) = '1' then
            R_T_APA_EFF <= T_apa;
          else
            R_T_APA_EFF <= T_aa;
          end if;
          assert L_ADDR(rcr_f_res3) = "000"
            report "bad rcr write: 22:20 not zero" severity error;
          assert L_ADDR(rcr_f_res2) = "0000000000"
            report "bad rcr write: 17: 8 not zero" severity error;
          assert L_ADDR(rcr_f_res1) = "00"
            report "bad rcr write:  6: 5 not zero" severity error;
          assert L_ADDR(rcr_f_dpd) = '1'
            report "bad rcr write:  dpd not '1'" severity error;
          assert L_ADDR(rcr_f_res0) = '0'
            report "bad rcr write:  3: 3 not zero" severity error;
          assert L_ADDR(rcr_f_par) = "000"
            report "bad rcr write:  par not '000'" severity error;

        when xcr_sel_bcr => 
          report "bcr written - not supported" severity error;
        when others =>
          report "bad select field" severity error;
      end case;
    end if;
  end process proc_cr;
    
  proc_data: process (DOUT, DOUT_VAL_EN, DOUT_VAL_AA, DOUT_VAL_PA, DOUT_VAL_OE,
                      DOUT_LZ_CE, DOUT_LZ_OE)
    variable idout : slv16 := (others=>'0');
  begin
    idout := DOUT;
    if DOUT_VAL_EN='0' or DOUT_VAL_AA='0' or
       DOUT_VAL_PA='0' or DOUT_VAL_OE='0' then
      idout := (others=>'X');
    end if;
    if DOUT_LZ_CE='0' or DOUT_LZ_OE='0' then
      idout := (others=>'Z');
    end if;
    DATA <= idout;
  end process proc_data;

  proc_mwait: process (CE)
  begin
    -- WT driver (just a dummy)
    if CE = '1' then
      MWAIT <= '1';
    else
      MWAIT <= 'Z';
    end if;
  end process proc_mwait;
  
end sim;
