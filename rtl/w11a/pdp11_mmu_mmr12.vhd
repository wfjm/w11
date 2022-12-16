-- $Id: pdp11_mmu_mmr12.vhd 1330 2022-12-16 17:52:40Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2006-2022 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    pdp11_mmu_mmr12 - syn
-- Description:    pdp11: mmu register mmr1 and mmr2
--
-- Dependencies:   ib_sel
-- Test bench:     tb/tb_pdp11_core (implicit)
-- Target Devices: generic
-- Tool versions:  ise 8.2-14.7; viv 2014.4-2022.1; ghdl 0.18-2.0.0
-- 
-- Revision History:
-- Date         Rev Version  Comment
-- 2022-12-12  1330   1.2.5  implement MMR2 instruction complete
-- 2022-08-30  1291   1.2.4  use ra_delta to steer mmr1 updates
-- 2022-08-13  1279   1.2.3  ssr->mmr rename
-- 2011-11-18   427   1.2.2  now numeric_std clean
-- 2010-10-23   335   1.2.1  use ib_sel
-- 2010-10-17   333   1.2    use ibus V2 interface
-- 2009-05-30   220   1.1.4  final removal of snoopers (were already commented)
-- 2008-08-22   161   1.1.3  rename ubf_ -> ibf_; use iblib
-- 2008-03-02   121   1.1.2  remove snoopers
-- 2008-01-05   110   1.1.1  rename IB_MREQ(ena->req) SRES(sel->ack, hold->busy)
-- 2007-12-30   107   1.1    use IB_MREQ/IB_SRES interface now
-- 2007-06-14    56   1.0.1  Use slvtypes.all
-- 2007-05-12    26   1.0    Initial version
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.iblib.all;
use work.pdp11.all;

-- ----------------------------------------------------------------------------

entity pdp11_mmu_mmr12 is               -- mmu register mmr1 and mmr2
  port (
    CLK : in slbit;                     -- clock
    CRESET : in slbit;                  -- cpu reset
    TRACE : in slbit;                   -- trace enable
    MONI : in mmu_moni_type;            -- MMU monitor port data
    VADDR : in slv16;                   -- virtual address
    IB_MREQ : in ib_mreq_type;          -- ibus request
    IB_SRES : out ib_sres_type          -- ibus response
  );
end pdp11_mmu_mmr12;

architecture syn of pdp11_mmu_mmr12 is

  constant ibaddr_mmr1 : slv16 := slv(to_unsigned(8#177574#,16));
  constant ibaddr_mmr2 : slv16 := slv(to_unsigned(8#177576#,16));
  
  subtype mmr1_ibf_rb_delta is integer range 15 downto 11;
  subtype mmr1_ibf_rb_num is integer range 10 downto 8;
  subtype mmr1_ibf_ra_delta is integer range 7 downto 3;
  subtype mmr1_ibf_ra_num is integer range 2 downto 0;

  signal IBSEL_MMR1 : slbit := '0';
  signal IBSEL_MMR2 : slbit := '0';
  signal R_MMR1 : mmu_mmr1_type := mmu_mmr1_init;
  signal R_MMR2 : slv16 := (others=>'0');
  signal N_MMR1 : mmu_mmr1_type := mmu_mmr1_init;
  signal N_MMR2 : slv16 := (others=>'0');

begin

  SEL_MMR1 : ib_sel
    generic map (
      IB_ADDR => ibaddr_mmr1)
    port map (
      CLK     => CLK,
      IB_MREQ => IB_MREQ,
      SEL     => IBSEL_MMR1
    );
  SEL_MMR2 : ib_sel
    generic map (
      IB_ADDR => ibaddr_mmr2)
    port map (
      CLK     => CLK,
      IB_MREQ => IB_MREQ,
      SEL     => IBSEL_MMR2
    );

  proc_ibres : process (IBSEL_MMR1, IBSEL_MMR2, IB_MREQ, R_MMR1, R_MMR2)
    variable mmr1out : slv16 := (others=>'0');
    variable mmr2out : slv16 := (others=>'0');
  begin

    mmr1out := (others=>'0');
    if IBSEL_MMR1 = '1' then
      mmr1out(mmr1_ibf_rb_delta) := R_MMR1.rb_delta;
      mmr1out(mmr1_ibf_rb_num)   := R_MMR1.rb_num;
      mmr1out(mmr1_ibf_ra_delta) := R_MMR1.ra_delta;
      mmr1out(mmr1_ibf_ra_num)   := R_MMR1.ra_num;
    end if;
    
    mmr2out := (others=>'0');
    if IBSEL_MMR2 = '1' then
      mmr2out := R_MMR2;
    end if;
     
    IB_SRES.dout <= mmr1out or mmr2out;
    IB_SRES.ack  <= (IBSEL_MMR1 or IBSEL_MMR2) and
                    (IB_MREQ.re or IB_MREQ.we); -- ack all
    IB_SRES.busy <= '0';

  end process proc_ibres;

  proc_regs : process (CLK)
  begin
    if rising_edge(CLK) then
      R_MMR1 <= N_MMR1;
      R_MMR2 <= N_MMR2;
    end if;
  end process proc_regs;

  proc_comb : process (CRESET, IBSEL_MMR1, IB_MREQ,
                       R_MMR1, R_MMR2, TRACE, MONI, VADDR)

    variable nmmr1 : mmu_mmr1_type := mmu_mmr1_init;
    variable nmmr2 : slv16 := (others=>'0');
    variable delta : slv5 := (others=>'0');
    
  begin

    nmmr1 := R_MMR1;
    nmmr2 := R_MMR2;
    delta := "0" & MONI.delta;

    if CRESET = '1' then
      nmmr1 := mmu_mmr1_init;
      nmmr2 := (others=>'0');
      
    elsif IBSEL_MMR1='1' and IB_MREQ.we='1' then
      
      if IB_MREQ.be1 = '1' then
        nmmr1.rb_delta := IB_MREQ.din(mmr1_ibf_rb_delta);
        nmmr1.rb_num   := IB_MREQ.din(mmr1_ibf_rb_num);
      end if;
      if IB_MREQ.be0 = '1' then
        nmmr1.ra_delta := IB_MREQ.din(mmr1_ibf_ra_delta);
        nmmr1.ra_num   := IB_MREQ.din(mmr1_ibf_ra_num);
      end if;
      
    elsif TRACE = '1' then

      if MONI.istart='1' or MONI.vstart='1' then
        nmmr1 := mmu_mmr1_init;
        nmmr2 := VADDR;

      elsif MONI.regmod = '1' then
        if R_MMR1.ra_delta = "00000" then
          nmmr1.ra_num := MONI.regnum;
          if MONI.isdec = '0' then
            nmmr1.ra_delta := delta;
          else
            nmmr1.ra_delta := slv(-signed(delta));
          end if;
        else
          nmmr1.rb_num := MONI.regnum;
          if MONI.isdec = '0' then
            nmmr1.rb_delta := delta;
          else
            nmmr1.rb_delta := slv(-signed(delta));
          end if;
        end if;
      end if;

    end if;

    N_MMR1 <= nmmr1;
    N_MMR2 <= nmmr2;

  end process proc_comb;

end syn;
