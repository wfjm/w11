-- $Id: pdp11_mmu.vhd 1331 2022-12-18 11:55:47Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2006-2022 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    pdp11_mmu - syn
-- Description:    pdp11: mmu - memory management unit
--
-- Dependencies:   pdp11_mmu_padr
--                 pdp11_mmu_mmr12
--                 ibus/ib_sres_or_3
--                 ibus/ib_sel
--
-- Test bench:     tb/tb_pdp11_core (implicit)
-- Target Devices: generic
-- Tool versions:  ise 8.2-14.7; viv 2014.4-2022.1; ghdl 0.18-2.0.0
--
-- Revision History:
-- Date         Rev Version  Comment
-- 2022-12-17  1331   1.4.7  some logic cleanup
-- 2022-12-12  1330   1.4.6  implement MMR0 instruction complete
-- 2022-11-29  1323   1.4.5  rename mmu_mmr0_type dspace->page_dspace
-- 2022-09-05  1294   1.4.4  BUGFIX: correct trap and PDR A logic
-- 2022-08-13  1279   1.4.3  ssr->mmr rename
-- 2011-11-18   427   1.4.2  now numeric_std clean
-- 2010-10-23   335   1.4.1  use ib_sel
-- 2010-10-17   333   1.4    use ibus V2 interface
-- 2010-06-20   307   1.3.7  rename cpacc to cacc in mmu_cntl_type
-- 2009-05-30   220   1.3.6  final removal of snoopers (were already commented)
-- 2009-05-09   213   1.3.5  BUGFIX: tie inst_compl permanentely '0'
--                           BUGFIX: set mmr0 trap_mmu even when traps disabled
-- 2008-08-22   161   1.3.4  rename pdp11_ibres_ -> ib_sres_, ubf_ -> ibf_
-- 2008-04-27   139   1.3.3  allow mmr1/2 tracing even with mmu_ena=0
-- 2008-04-25   138   1.3.2  add BRESET port, clear mmr0/3 with BRESET
-- 2008-03-02   121   1.3.1  remove snoopers
-- 2008-02-24   119   1.3    return always mapped address in PADDRH; remove
--                           cpacc handling; PADDR generation now on _vmbox
-- 2008-01-05   110   1.2.1  rename _mmu_regs -> _mmu_sadr
--                           rename IB_MREQ(ena->req) SRES(sel->ack, hold->busy)
-- 2008-01-01   109   1.2    use pdp11_mmu_regs (rather than _regset)
-- 2007-12-31   108   1.1.1  remove SADR memory address mux (-> _mmu_regfile)
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

entity pdp11_mmu is                     -- mmu - memory management unit
  port (
    CLK : in slbit;                     -- clock
    CRESET : in slbit;                  -- cpu reset
    BRESET : in slbit;                  -- bus reset
    CNTL : in mmu_cntl_type;            -- control port
    VADDR : in slv16;                   -- virtual address
    MONI : in mmu_moni_type;            -- monitor port
    STAT : out mmu_stat_type;           -- status port
    PADDRH : out slv16;                 -- physical address (upper 16 bit)
    IB_MREQ: in ib_mreq_type;           -- ibus request
    IB_SRES: out ib_sres_type           -- ibus response
  );
end pdp11_mmu;

architecture syn of pdp11_mmu is
  
  constant ibaddr_mmr0 : slv16 := slv(to_unsigned(8#177572#,16));
  constant ibaddr_mmr3 : slv16 := slv(to_unsigned(8#172516#,16));

  constant mmr0_ibf_abo_nonres : integer := 15;
  constant mmr0_ibf_abo_length : integer := 14;
  constant mmr0_ibf_abo_rdonly : integer := 13;
  constant mmr0_ibf_trap_mmu : integer := 12;
  constant mmr0_ibf_ena_trap : integer := 9;
  constant mmr0_ibf_inst_compl : integer := 7;
  subtype  mmr0_ibf_page_mode is integer range 6 downto 5;
  constant mmr0_ibf_page_dspace : integer := 4;
  subtype  mmr0_ibf_page_num is integer range 3 downto 1;
  constant mmr0_ibf_ena_mmu : integer := 0;
  
  constant mmr3_ibf_ena_ubmap : integer := 5;
  constant mmr3_ibf_ena_22bit : integer := 4;
  constant mmr3_ibf_dspace_km : integer := 2;
  constant mmr3_ibf_dspace_sm : integer := 1;
  constant mmr3_ibf_dspace_um : integer := 0;

  signal IBSEL_MMR0 : slbit := '0';     -- ibus select MMR0
  signal IBSEL_MMR3 : slbit := '0';     -- ibus select MMR3

  signal R_MMR0 : mmu_mmr0_type := mmu_mmr0_init;
  signal N_MMR0 : mmu_mmr0_type := mmu_mmr0_init;

  signal R_MMR3 : mmu_mmr3_type := mmu_mmr3_init;

  signal APN : slv4 := "0000";          -- augmented page number (1+3 bit)
  signal AIB_WE : slbit := '0';         -- update AIB
  signal AIB_SETA : slbit := '0';       -- set A bit in access information bits
  signal AIB_SETW : slbit := '0';       -- set W bit in access information bits

  signal TRACE : slbit := '0';          -- enable tracing in mmr1/2
  signal DSPACE : slbit := '0';         -- use dspace

  signal IB_SRES_PADR  : ib_sres_type := ib_sres_init;
  signal IB_SRES_MMR12 : ib_sres_type := ib_sres_init;
  signal IB_SRES_MMR03 : ib_sres_type := ib_sres_init;

  signal PARPDR : parpdr_type := parpdr_init;

begin

  PADR : pdp11_mmu_padr port map (
    CLK      => CLK,
    MODE     => CNTL.mode,
    APN      => APN,
    AIB_WE   => AIB_WE,
    AIB_SETA => AIB_SETA,
    AIB_SETW => AIB_SETW,
    PARPDR   => PARPDR,
    IB_MREQ  => IB_MREQ,
    IB_SRES  => IB_SRES_PADR);

  MMR12 : pdp11_mmu_mmr12 port map (
    CLK     => CLK,
    CRESET  => CRESET,
    TRACE   => TRACE,
    MONI    => MONI,
    VADDR   => VADDR,
    IB_MREQ => IB_MREQ,
    IB_SRES => IB_SRES_MMR12);

  SRES_OR : ib_sres_or_3
    port map (
      IB_SRES_1  => IB_SRES_PADR,
      IB_SRES_2  => IB_SRES_MMR12,
      IB_SRES_3  => IB_SRES_MMR03,
      IB_SRES_OR => IB_SRES);

  SEL_MMR0 : ib_sel
    generic map (
      IB_ADDR => ibaddr_mmr0)
    port map (
      CLK     => CLK,
      IB_MREQ => IB_MREQ,
      SEL     => IBSEL_MMR0
    );
  SEL_MMR3 : ib_sel
    generic map (
      IB_ADDR => ibaddr_mmr3)
    port map (
      CLK     => CLK,
      IB_MREQ => IB_MREQ,
      SEL     => IBSEL_MMR3
    );

  proc_ibres : process (IBSEL_MMR0, IBSEL_MMR3, IB_MREQ, R_MMR0, R_MMR3)

    variable mmr0out : slv16 := (others=>'0');
    variable mmr3out : slv16 := (others=>'0');

  begin

    mmr0out := (others=>'0');
    if IBSEL_MMR0 = '1' then
      mmr0out(mmr0_ibf_abo_nonres) := R_MMR0.abo_nonres;
      mmr0out(mmr0_ibf_abo_length) := R_MMR0.abo_length;
      mmr0out(mmr0_ibf_abo_rdonly) := R_MMR0.abo_rdonly;
      mmr0out(mmr0_ibf_trap_mmu)   := R_MMR0.trap_mmu;
      mmr0out(mmr0_ibf_ena_trap)   := R_MMR0.ena_trap;
      mmr0out(mmr0_ibf_inst_compl) := R_MMR0.inst_compl;
      mmr0out(mmr0_ibf_page_mode)  := R_MMR0.page_mode;
      mmr0out(mmr0_ibf_page_dspace):= R_MMR0.page_dspace;
      mmr0out(mmr0_ibf_page_num)   := R_MMR0.page_num;
      mmr0out(mmr0_ibf_ena_mmu)    := R_MMR0.ena_mmu;
    end if;
    
    mmr3out := (others=>'0');
    if IBSEL_MMR3 = '1' then
      mmr3out(mmr3_ibf_ena_ubmap) := R_MMR3.ena_ubmap;
      mmr3out(mmr3_ibf_ena_22bit) := R_MMR3.ena_22bit;
      mmr3out(mmr3_ibf_dspace_km) := R_MMR3.dspace_km;
      mmr3out(mmr3_ibf_dspace_sm) := R_MMR3.dspace_sm;
      mmr3out(mmr3_ibf_dspace_um) := R_MMR3.dspace_um;
    end if;
 
    IB_SRES_MMR03.dout <= mmr0out or mmr3out;
    IB_SRES_MMR03.ack  <= (IBSEL_MMR0 or IBSEL_MMR3) and
                          (IB_MREQ.re or IB_MREQ.we); -- ack all
    IB_SRES_MMR03.busy <= '0';

  end process proc_ibres;

  proc_mmr0 : process (CLK)
  begin
    if rising_edge(CLK) then
      if BRESET = '1' then
        R_MMR0 <= mmu_mmr0_init;
      else
        R_MMR0 <= N_MMR0;
      end if;
    end if;
  end process proc_mmr0;

  proc_mmr3 : process (CLK)
  begin
    if rising_edge(CLK) then
      if BRESET = '1' then
        R_MMR3 <= mmu_mmr3_init;
      elsif IBSEL_MMR3='1' and IB_MREQ.we='1' then
        if IB_MREQ.be0 = '1' then
          R_MMR3.ena_ubmap <= IB_MREQ.din(mmr3_ibf_ena_ubmap);
          R_MMR3.ena_22bit <= IB_MREQ.din(mmr3_ibf_ena_22bit);
          R_MMR3.dspace_km <= IB_MREQ.din(mmr3_ibf_dspace_km);
          R_MMR3.dspace_sm <= IB_MREQ.din(mmr3_ibf_dspace_sm);
          R_MMR3.dspace_um <= IB_MREQ.din(mmr3_ibf_dspace_um);
        end if;
      end if;
    end if;
  end process proc_mmr3;

  proc_paddr : process (R_MMR0, R_MMR3, CNTL, PARPDR, VADDR)
    
    variable ipaddrh : slv16 := (others=>'0');
    variable dspace_ok : slbit := '0';
    variable dspace_en : slbit := '0';
    variable apf : slv3 := (others=>'0'); -- va: active page field
    variable bn : slv7 := (others=>'0');  -- va: block number
    variable iapn : slv4 := (others=>'0');-- augmented page number
    
  begin
    
    apf := VADDR(15 downto 13);
    bn := VADDR(12 downto 6);

    dspace_en := '0';
    case CNTL.mode is
      when "00" => dspace_en := R_MMR3.dspace_km;
      when "01" => dspace_en := R_MMR3.dspace_sm;
      when "11" => dspace_en := R_MMR3.dspace_um;
      when others => null;
    end case;
    dspace_ok := CNTL.dspace and dspace_en;
    
    iapn(3) := dspace_ok;
    iapn(2 downto 0) := apf;

    ipaddrh := slv(unsigned("000000000"&bn) + unsigned(PARPDR.paf));

    DSPACE <= dspace_ok;
    APN    <= iapn;
    PADDRH <= ipaddrh;
    
  end process proc_paddr;
                         
  proc_nmmr0 : process (R_MMR0, R_MMR3, IB_MREQ, IBSEL_MMR0, DSPACE,
                        CNTL, MONI, PARPDR, VADDR)
    
    variable nmmr0 : mmu_mmr0_type := mmu_mmr0_init;
    variable apf : slv3 := (others=>'0');
    variable bn : slv7 := (others=>'0');
    variable abo_nonres : slbit := '0';
    variable abo_length : slbit := '0';
    variable abo_rdonly : slbit := '0';
    variable mmr_freeze : slbit := '0';
    variable doabort : slbit := '0';
    variable dotrap  : slbit := '0';
    variable dotrace : slbit := '0';
    variable iswrite : slbit := '0';

  begin
    
    nmmr0 := R_MMR0;

    AIB_WE   <= '0';
    AIB_SETA <= '0';
    AIB_SETW <= '0';

    mmr_freeze := R_MMR0.abo_nonres or R_MMR0.abo_length or R_MMR0.abo_rdonly;
    dotrace := not(CNTL.cacc or mmr_freeze);
    iswrite := CNTL.wacc or CNTL.macc;

    apf := VADDR(15 downto 13);
    bn := VADDR(12 downto 6);

    abo_nonres := '0';
    abo_length := '0';
    abo_rdonly := '0';
    doabort := '0';
    dotrap  := '0';
    
    if PARPDR.ed = '0' then             -- ed=0: upward expansion
      if unsigned(bn) > unsigned(PARPDR.plf) then
        abo_length := '1';
      end if;
    else                                -- ed=0: downward expansion
      if unsigned(bn) < unsigned(PARPDR.plf) then
        abo_length := '1';
      end if;
    end if;

    -- ACF decision logic
    --   w11 has 4 memory cycle types, the ACF is based only on read or write
    --     wacc='0' macc'0' : read  cycle         --> read
    --     wacc='1' macc'0' : write cycle         --> write
    --     wacc='0' macc'1' : read  part of rmw   --> write
    --     wacc='1' macc'1' : write part of rmw   --> write
    -- Depending of ACF the MMU aborts, queues a trap, sets A and W bit in PDR
    --   ACF   abort  trap  Comment
    --   000  nonres     -  non-resident: abort all accesses
    --   001  rdonly     R  read-only:    abort on write, trap on read
    --   010  rdonly        read-only:    abort on write
    --   011  nonres     -  unused:       abort all accesses
    --   100       -   R+W  read/write:   no abort, trap on read or write
    --   101       -     W  read/write:   no abort, trap on write
    --   110       -     -  read/write:   no abort, no trap
    --   111  nonres     -  unused:       abort all accesses
    --
    -- The PDR W bit is set for non-aborted write accesses
    -- The PDR A bit is set if the trap condition is fulfilled and not aborted
    
    case PARPDR.acf is                  -- evaluate accecc control field

      when "000" =>                     -- page non-resident
        abo_nonres := '1';

      when "001" =>                     -- read-only; trap on read
        if iswrite='1' then
          abo_rdonly := '1';
        end if;
        dotrap := not iswrite;

      when "010" =>                     -- read-only
        if iswrite='1' then
          abo_rdonly := '1';
        end if;

      when "100" =>                     -- read/write; trap on read&write
        dotrap := '1';

      when "101" =>                     -- read/write; trap on write
        dotrap := iswrite;

      when "110" => null;               -- read/write;

      when others =>                    -- unused codes: abort access
        abo_nonres := '1';
    end case;

    STAT <= mmu_stat_init;

    if IBSEL_MMR0='1' and IB_MREQ.we='1' then

      if IB_MREQ.be1 = '1' then
        nmmr0.abo_nonres := IB_MREQ.din(mmr0_ibf_abo_nonres);
        nmmr0.abo_length := IB_MREQ.din(mmr0_ibf_abo_length);
        nmmr0.abo_rdonly := IB_MREQ.din(mmr0_ibf_abo_rdonly);
        nmmr0.trap_mmu   := IB_MREQ.din(mmr0_ibf_trap_mmu);
        nmmr0.ena_trap   := IB_MREQ.din(mmr0_ibf_ena_trap);
      end if;
      if IB_MREQ.be0 = '1' then
        nmmr0.ena_mmu := IB_MREQ.din(mmr0_ibf_ena_mmu);
      end if;
      
    elsif R_MMR0.ena_mmu='1' and CNTL.cacc='0' then

      if mmr_freeze = '0' then          -- independent of an active request will
        nmmr0.inst_compl := MONI.vflow; -- the inst_compl flag follow vflow
      end if;

      if CNTL.req = '1' then
        AIB_WE <= '1';
        if mmr_freeze = '0' then
          nmmr0.abo_nonres  := abo_nonres;
          nmmr0.abo_length  := abo_length;
          nmmr0.abo_rdonly  := abo_rdonly;
          nmmr0.page_dspace := DSPACE;
          nmmr0.page_num    := apf;
          nmmr0.page_mode   := CNTL.mode;
        end if;
        doabort := abo_nonres or abo_length or abo_rdonly;

        if doabort = '0' then
          AIB_SETA <= dotrap;
          AIB_SETW <= iswrite;
          if dotrap='1'  then           -- if trap condition fulfilled
            nmmr0.trap_mmu := '1';      -- set trap_mmu flag
            if R_MMR0.ena_trap='1' and R_MMR0.trap_mmu='0'  then
              STAT.trap <= '1';         -- trap if enabled and not blocked
            end if;
          end if;
        end if;

      end if;  -- CNTL.req = '1'
    end if;  -- R_MMR0.ena_mmu='1' and CNTL.cacc='0'

    nmmr0.trace_prev := dotrace;

    if MONI.trace_prev = '0' then
      TRACE <= dotrace;
    else
      TRACE <= R_MMR0.trace_prev;
    end if;

    N_MMR0 <= nmmr0;

    if R_MMR0.ena_mmu='1' and CNTL.cacc='0' then
      STAT.vaok <= not doabort;
    else
      STAT.vaok <= '1';
    end if;

    STAT.ena_mmu   <= R_MMR0.ena_mmu;
    STAT.ena_22bit <= R_MMR3.ena_22bit;
    STAT.ena_ubmap <= R_MMR3.ena_ubmap;
    
  end process proc_nmmr0;

end syn;
