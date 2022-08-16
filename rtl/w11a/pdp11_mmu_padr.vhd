-- $Id: pdp11_mmu_padr.vhd 1279 2022-08-14 08:02:21Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2006-2022 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    pdp11_mmu_sadr - syn
-- Description:    pdp11: mmu PAR/PDR register set
--
-- Dependencies:   memlib/ram_1swar_gen
--
-- Test bench:     tb/tb_pdp11_core (implicit)
-- Target Devices: generic
-- Tool versions:  ise 8.2-14.7; viv 2014.4-2022.1; ghdl 0.18-2.0.0
--
-- Revision History:
-- Date         Rev Version  Comment
-- 2022-08-13  1279   1.3.4  ssr->mmr rename
-- 2011-11-18   427   1.3.3  now numeric_std clean
-- 2010-12-30   351   1.3.2  BUGFIX: fix sensitivity list of proc_eaddr
-- 2010-10-23   335   1.3.1  change proc_eaddr logic, shorten logic path
-- 2010-10-17   333   1.3    use ibus V2 interface
-- 2008-08-22   161   1.2.2  rename ubf_ -> ibf_; use iblib
-- 2008-01-05   110   1.2.1  rename _mmu_regs -> _mmu_sadr
--                           rename IB_MREQ(ena->req) SRES(sel->ack, hold->busy)
-- 2008-01-01   109   1.2    renamed from _mmu_regfile.
--                           redesign of _mmu register file, use one large dram.
--                           logic from _mmu_regfile, interface from _mmu_regset
-- 2007-12-30   108   1.1.1  use ubf_byte[01]; move SADR memory address mux here
-- 2007-12-30   107   1.1    use IB_MREQ/IB_SRES interface now
-- 2007-06-14    56   1.0.1  Use slvtypes.all
-- 2007-05-12    26   1.0    Initial version
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.memlib.all;
use work.iblib.all;
use work.pdp11.all;

-- ----------------------------------------------------------------------------

entity pdp11_mmu_padr is                -- mmu PAR/PDR register set
  port (
    CLK : in slbit;                     -- clock
    MODE : in slv2;                     -- mode
    APN : in slv4;                      -- augmented page number (1+3 bit)
    AIB_WE : in slbit;                  -- update AIB
    AIB_SETA : in slbit;                -- set access AIB
    AIB_SETW : in slbit;                -- set write AIB
    PARPDR : out parpdr_type;           -- combined PAR/PDR
    IB_MREQ : in ib_mreq_type;          -- ibus request
    IB_SRES : out ib_sres_type          -- ibus response
  );
end pdp11_mmu_padr;

architecture syn of pdp11_mmu_padr is

  --             bit 1 111 1
  --             bit 5 432 109 876 543 210
  --
  -- kmdr 172300 ->  1 111 010 011 000 000
  -- kmar 172340 ->  1 111 010 011 100 000
  -- smdr 172200 ->  1 111 010 010 000 000
  -- smar 172240 ->  1 111 010 010 100 000
  -- umdr 177600 ->  1 111 111 110 000 000
  -- umar 177640 ->  1 111 111 110 100 000
  --
  --  mode => (addr(8), not addr(6))   [Note: km "00" sm "01" um "11"]
  
  constant ibaddr_kmdar : slv16 := slv(to_unsigned(8#172300#,16));
  constant ibaddr_smdar : slv16 := slv(to_unsigned(8#172200#,16));
  constant ibaddr_umdar : slv16 := slv(to_unsigned(8#177600#,16));

  subtype pdr_ibf_plf is integer range 14 downto 8;
  subtype pdr_ibf_aib is integer range  7 downto 6;
  subtype pdr_ibf_acf is integer range  3 downto 0;

  signal PADR_ADDR : slv6 := (others=>'0'); -- address (from mmu or ibus)

  signal PAR_HIGH_WE : slbit := '0';    -- write enables
  signal PAR_LOW_WE : slbit := '0';     -- ...
  signal PDR_PLF_WE : slbit := '0';     -- ...
  signal PDR_AIB_WE : slbit := '0';     -- ...
  signal PDR_LOW_WE : slbit := '0';     -- ...

  signal R_IBSEL_DR : slbit := '0';     -- DR's selected from ibus
  signal R_IBSEL_AR : slbit := '0';     -- AR's selected from ibus

  signal PAF : slv16 := (others=>'0');  -- current PAF
  signal PLF : slv7 := (others=>'0');   -- current PLF
  signal AIB : slv2 := "00";            -- current AIB flags
  signal N_AIB : slv2 := "00";          -- next AIB flags
  signal ED_ACF : slv4 := "0000";       -- current ED & ACF
  
begin
  
  PAR_HIGH : ram_1swar_gen
    generic map (
      AWIDTH => 6,
      DWIDTH => 8)
    port map (
      CLK  => CLK,
      WE   => PAR_HIGH_WE,
      ADDR => PADR_ADDR,
      DI   => IB_MREQ.din(ibf_byte1),
      DO   => PAF(ibf_byte1));

  PAR_LOW : ram_1swar_gen
    generic map (
      AWIDTH => 6,
      DWIDTH => 8)
    port map (
      CLK  => CLK,
      WE   => PAR_LOW_WE,
      ADDR => PADR_ADDR,
      DI   => IB_MREQ.din(ibf_byte0),
      DO   => PAF(ibf_byte0));

  PDR_PLF : ram_1swar_gen
    generic map (
      AWIDTH => 6,
      DWIDTH => 7)
    port map (
      CLK  => CLK,
      WE   => PDR_PLF_WE,
      ADDR => PADR_ADDR,
      DI   => IB_MREQ.din(pdr_ibf_plf),
      DO   => PLF);

  PDR_AIB : ram_1swar_gen
    generic map (
      AWIDTH => 6,
      DWIDTH => 2)
    port map (
      CLK  => CLK,
      WE   => PDR_AIB_WE,
      ADDR => PADR_ADDR,
      DI   => N_AIB,
      DO   => AIB);
    
  PDR_LOW : ram_1swar_gen
    generic map (
      AWIDTH => 6,
      DWIDTH => 4)
    port map (
      CLK  => CLK,
      WE   => PDR_LOW_WE,
      ADDR => PADR_ADDR,
      DI   => IB_MREQ.din(pdr_ibf_acf),
      DO   => ED_ACF);

  -- determine IBSEL's and the address for accessing the PADR's

  proc_ibsel: process (CLK)
    variable ibsel_dr : slbit := '0';
    variable ibsel_ar : slbit := '0';
  begin
    if rising_edge(CLK) then
      ibsel_dr := '0';
      ibsel_ar := '0';
      if IB_MREQ.aval = '1' then
        if IB_MREQ.addr(12 downto 6)=ibaddr_kmdar(12 downto 6) or
           IB_MREQ.addr(12 downto 6)=ibaddr_smdar(12 downto 6) or
           IB_MREQ.addr(12 downto 6)=ibaddr_umdar(12 downto 6) then
          if IB_MREQ.addr(5) = '0' then
            ibsel_dr := '1';
          else
            ibsel_ar := '1';
          end if;
        end if;
      end if;
      R_IBSEL_DR <= ibsel_dr;
      R_IBSEL_AR <= ibsel_ar;
    end if;
  end process proc_ibsel;
  
  proc_ibres : process (R_IBSEL_DR, R_IBSEL_AR, IB_MREQ, PAF, PLF, AIB, ED_ACF)
    variable parout : slv16 := (others=>'0');  -- IB par out
    variable pdrout : slv16 := (others=>'0');  -- IB pdr out
  begin

    parout := (others=>'0');
    if R_IBSEL_AR = '1' then
      parout := PAF;
    end if;
    
    pdrout := (others=>'0');
    if R_IBSEL_DR = '1' then
      pdrout(pdr_ibf_plf) := PLF;
      pdrout(pdr_ibf_aib) := AIB;
      pdrout(pdr_ibf_acf) := ED_ACF;
    end if;

    IB_SRES.dout <= parout or pdrout;
    IB_SRES.ack  <= (R_IBSEL_DR or R_IBSEL_AR) and
                    (IB_MREQ.re or IB_MREQ.we); -- ack all
    IB_SRES.busy <= '0';

  end process proc_ibres;

  -- the eaddr select should be done as early as possible, it is in the
  -- mmu paadr logic path. Currently it's derived from 4 flops. If that's
  -- to slow just use IB_MREQ.we or IB_MREQ.we, that should be sufficient
  -- and reduce the eaddr mux to a 4-input LUT. Last resort is a 2 cycle ibus
  -- access with a state flop marking the 2nd cycle of a re/we transaction.
  
  proc_eaddr: process (IB_MREQ, MODE, APN, R_IBSEL_DR, R_IBSEL_AR)
    variable eaddr : slv6 := (others=>'0');
    variable idr : slbit := '0';
    variable iar : slbit := '0';
  begin
    
    eaddr := MODE & APN;
    
    if (R_IBSEL_DR='1' or R_IBSEL_AR='1') and
       (IB_MREQ.re='1' or IB_MREQ.we='1') then
      eaddr(5)          := IB_MREQ.addr(8);
      eaddr(4)          := not IB_MREQ.addr(6);
      eaddr(3 downto 0) := IB_MREQ.addr(4 downto 1);
    end if;
    
    PADR_ADDR    <= eaddr;

  end process proc_eaddr;

  proc_comb : process (R_IBSEL_AR, R_IBSEL_DR, IB_MREQ, AIB_WE,
                       AIB_SETA, AIB_SETW,
                       PAF, PLF, AIB, ED_ACF)
  begin

    N_AIB <= "00";
    PAR_HIGH_WE <= '0';
    PAR_LOW_WE <= '0';
    PDR_PLF_WE <= '0';
    PDR_AIB_WE <= '0';
    PDR_LOW_WE <= '0';
    
    if IB_MREQ.we = '1' then
      if R_IBSEL_AR = '1' then
        if IB_MREQ.be1 = '1' then
          PAR_HIGH_WE <= '1';
        end if;
        if IB_MREQ.be0 = '1' then
          PAR_LOW_WE <= '1';
        end if;
      end if;

      if R_IBSEL_DR = '1' then
        if IB_MREQ.be1 = '1' then
          PDR_PLF_WE <= '1';
        end if;
        if IB_MREQ.be0 = '1' then
          PDR_LOW_WE <= '1';
        end if;
      end if;

      if (R_IBSEL_AR or R_IBSEL_DR)='1' then
        N_AIB <= "00";
        PDR_AIB_WE <= '1';
      end if;
    end if;

    if AIB_WE = '1' then
      N_AIB(0) <= AIB(0) or AIB_SETW;
      N_AIB(1) <= AIB(1) or AIB_SETA;
      PDR_AIB_WE  <= '1';
    end if;

    PARPDR.paf <= PAF;
    PARPDR.plf <= PLF;
    PARPDR.ed  <= ED_ACF(3);
    PARPDR.acf <= ED_ACF(2 downto 0);
    
  end process proc_comb;
  
end syn;
