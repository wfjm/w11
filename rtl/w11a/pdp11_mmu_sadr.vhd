-- $Id: pdp11_mmu_sadr.vhd 314 2010-07-09 17:38:41Z mueller $
--
-- Copyright 2006-2008 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    pdp11_mmu_sadr - syn
-- Description:    pdp11: mmu SAR/SDR register set
--
-- Dependencies:   memlib/ram_1swar_gen
--
-- Test bench:     tb/tb_pdp11_core (implicit)
-- Target Devices: generic
-- Tool versions:  xst 8.1, 8.2, 9.1, 9.2; ghdl 0.18-0.25
-- Revision History: 
-- Date         Rev Version  Comment
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
use ieee.std_logic_arith.all;

use work.slvtypes.all;
use work.memlib.all;
use work.iblib.all;
use work.pdp11.all;

-- ----------------------------------------------------------------------------

entity pdp11_mmu_sadr is                -- mmu SAR/SDR register set
  port (
    CLK : in slbit;                     -- clock
    MODE : in slv2;                     -- mode
    ASN : in slv4;                      -- augmented segment number (1+3 bit)
    AIB_WE : in slbit;                  -- update AIB
    AIB_SETA : in slbit;                -- set access AIB
    AIB_SETW : in slbit;                -- set write AIB
    SARSDR : out sarsdr_type;           -- combined SAR/SDR
    IB_MREQ : in ib_mreq_type;          -- ibus request
    IB_SRES : out ib_sres_type          -- ibus response
  );
end pdp11_mmu_sadr;

architecture syn of pdp11_mmu_sadr is

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
  
  constant ibaddr_kmdar : slv16 := conv_std_logic_vector(8#172300#,16);
  constant ibaddr_smdar : slv16 := conv_std_logic_vector(8#172200#,16);
  constant ibaddr_umdar : slv16 := conv_std_logic_vector(8#177600#,16);

  subtype sdr_ibf_slf is integer range 14 downto 8;
  subtype sdr_ibf_aib is integer range  7 downto 6;
  subtype sdr_ibf_acf is integer range  3 downto 0;

  signal SADR_ADDR : slv6 := (others=>'0'); -- address (from mmu or ibus)

  signal SAR_HIGH_WE : slbit := '0';    -- write enables
  signal SAR_LOW_WE : slbit := '0';     -- ...
  signal SDR_SLF_WE : slbit := '0';     -- ...
  signal SDR_AIB_WE : slbit := '0';     -- ...
  signal SDR_LOW_WE : slbit := '0';     -- ...

  signal IBSEL_DR : slbit := '0';
  signal IBSEL_AR : slbit := '0';

  signal SAF : slv16 := (others=>'0');  -- current SAF
  signal SLF : slv7 := (others=>'0');   -- current SLF
  signal AIB : slv2 := "00";            -- current AIB flags
  signal NEXT_AIB : slv2 := "00";       -- next AIB flags
  signal ED_ACF : slv4 := "0000";       -- current ED & ACF
  
begin
  
  SAR_HIGH : ram_1swar_gen
    generic map (
      AWIDTH => 6,
      DWIDTH => 8)
    port map (
      CLK  => CLK,
      WE   => SAR_HIGH_WE,
      ADDR => SADR_ADDR,
      DI   => IB_MREQ.din(ibf_byte1),
      DO   => SAF(ibf_byte1));

  SAR_LOW : ram_1swar_gen
    generic map (
      AWIDTH => 6,
      DWIDTH => 8)
    port map (
      CLK  => CLK,
      WE   => SAR_LOW_WE,
      ADDR => SADR_ADDR,
      DI   => IB_MREQ.din(ibf_byte0),
      DO   => SAF(ibf_byte0));

  SDR_SLF : ram_1swar_gen
    generic map (
      AWIDTH => 6,
      DWIDTH => 7)
    port map (
      CLK  => CLK,
      WE   => SDR_SLF_WE,
      ADDR => SADR_ADDR,
      DI   => IB_MREQ.din(sdr_ibf_slf),
      DO   => SLF);

  SDR_AIB : ram_1swar_gen
    generic map (
      AWIDTH => 6,
      DWIDTH => 2)
    port map (
      CLK  => CLK,
      WE   => SDR_AIB_WE,
      ADDR => SADR_ADDR,
      DI   => NEXT_AIB,
      DO   => AIB);
    
  SDR_LOW : ram_1swar_gen
    generic map (
      AWIDTH => 6,
      DWIDTH => 4)
    port map (
      CLK  => CLK,
      WE   => SDR_LOW_WE,
      ADDR => SADR_ADDR,
      DI   => IB_MREQ.din(sdr_ibf_acf),
      DO   => ED_ACF);

  -- determibe IBSEL's and the address for accessing the SADR's
  
  proc_ibsel: process (IB_MREQ, MODE, ASN)
    variable iaddr : slv6 := (others=>'0');
    variable idr : slbit := '0';
    variable iar : slbit := '0';
  begin
    
    iaddr := MODE & ASN;
    idr := '0';
    iar := '0';
    
    if IB_MREQ.req = '1' then
      iaddr(5)          := IB_MREQ.addr(8);
      iaddr(4)          := not IB_MREQ.addr(6);
      iaddr(3 downto 0) := IB_MREQ.addr(4 downto 1);
      if IB_MREQ.addr(12 downto 6)=ibaddr_kmdar(12 downto 6) or
         IB_MREQ.addr(12 downto 6)=ibaddr_smdar(12 downto 6) or
         IB_MREQ.addr(12 downto 6)=ibaddr_umdar(12 downto 6) then
        if IB_MREQ.addr(5) = '0' then
          idr := '1';
        else
          iar := '1';
        end if;
      end if;
    end if;
    
    SADR_ADDR    <= iaddr;
--  SADR_ADDR    <= iaddr(3) & iaddr(5 downto 4) & iaddr(2 downto 0);
    IBSEL_DR     <= idr;
    IBSEL_AR     <= iar;
    IB_SRES.ack  <= idr or iar;
    IB_SRES.busy <= '0';
    
  end process proc_ibsel;

  proc_ubdout : process (IBSEL_DR, IBSEL_AR, SAF, SLF, AIB, ED_ACF)    
    variable sarout : slv16 := (others=>'0');  -- IB sar out
    variable sdrout : slv16 := (others=>'0');  -- IB sdr out
  begin

    sarout := (others=>'0');
    if IBSEL_AR = '1' then
      sarout := SAF;
    end if;
    
    sdrout := (others=>'0');
    if IBSEL_DR = '1' then
      sdrout(sdr_ibf_slf) := SLF;
      sdrout(sdr_ibf_aib) := AIB;
      sdrout(sdr_ibf_acf) := ED_ACF;
    end if;

    IB_SRES.dout <= sarout or sdrout;

  end process proc_ubdout;

  proc_comb : process (IBSEL_AR, IBSEL_DR, IB_MREQ, AIB_WE, AIB_SETA, AIB_SETW,
                       SAF, SLF, AIB, ED_ACF)
  begin 

    NEXT_AIB <= "00";
    SAR_HIGH_WE <= '0';
    SAR_LOW_WE <= '0';
    SDR_SLF_WE <= '0';
    SDR_AIB_WE <= '0';
    SDR_LOW_WE <= '0';
    
    if IB_MREQ.we = '1' then
      if IBSEL_AR = '1' then
        if IB_MREQ.be1 = '1' then
          SAR_HIGH_WE <= '1';
        end if;
        if IB_MREQ.be0 = '1' then
          SAR_LOW_WE <= '1';
        end if;
      end if;

      if IBSEL_DR = '1' then
        if IB_MREQ.be1 = '1' then
          SDR_SLF_WE <= '1';
        end if;
        if IB_MREQ.be0 = '1' then
          SDR_LOW_WE <= '1';
        end if;
      end if;

      if (IBSEL_AR or IBSEL_DR)='1' then
        NEXT_AIB <= "00";
        SDR_AIB_WE <= '1';
      end if;
    end if;

    if AIB_WE = '1' then
      NEXT_AIB(0) <= AIB(0) or AIB_SETW;
      NEXT_AIB(1) <= AIB(1) or AIB_SETA;
      SDR_AIB_WE  <= '1';
    end if;

    SARSDR.saf <= SAF;
    SARSDR.slf <= SLF;
    SARSDR.ed  <= ED_ACF(3);
    SARSDR.acf <= ED_ACF(2 downto 0);
    
  end process proc_comb;
  
end syn;
