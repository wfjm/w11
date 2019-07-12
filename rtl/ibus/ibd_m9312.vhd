-- $Id: ibd_m9312.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2019- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    ibd_m9312 - syn
-- Description:    ibus dev: M9312
--
-- Dependencies:   memlib/ram_1swsr_wfirst_gen
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  ise 14.7; viv 2017.2; ghdl 0.35
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2019-04-28  1142   1.0    Initial version 
------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.memlib.all;
use work.iblib.all;

-- ----------------------------------------------------------------------------
entity ibd_m9312 is                     -- ibus dev: M9312
                                        -- fixed address: 165***,173***
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- system reset
    IB_MREQ : in ib_mreq_type;          -- ibus request
    IB_SRES : out ib_sres_type          -- ibus response
  );
end ibd_m9312;

architecture syn of ibd_m9312 is
  --                              1 111 110 000 000 000
  --                              5 432 109 876 543 210
  -- Note: LO-ROM addr is 165xxx: 1 110 101 xxx xxx xx0
  --       HI-ROM addr is 173xxx: 1 111 011 xxx xxx xx0
  --       --> addr(12) is 0 for LO and 1 for HI
  constant ibaddr_m9312_lo : slv16 := slv(to_unsigned(8#165000#,16));
  constant ibaddr_m9312_hi : slv16 := slv(to_unsigned(8#173000#,16));

  constant csr_ibf_locwe :  integer :=  7;
  constant csr_ibf_enahi :  integer :=  1;
  constant csr_ibf_enalo :  integer :=  0;

  type regs_type is record              -- state registers
    ibselcsr : slbit;                   -- ibus select csr: LO-ROM(0)
    ibselmem : slbit;                   -- ibus select mem: LO-ROM or HI-ROM
    locwe : slbit;                      -- write enable for loc access
    enahi : slbit;                      -- HI-ROM loc visible
    enalo : slbit;                      -- LO-ROM loc visible
  end record regs_type;

  constant regs_init : regs_type := (
    '0','0',                            -- ibselcsr,ibselmem
    '0',                                -- locwe
    '0','0'                             -- enahi,enalo
  );

  signal R_REGS : regs_type := regs_init;
  signal N_REGS : regs_type := regs_init;
  
  signal BRAM_WE : slbit := '0';
  signal BRAM_DO   : slv16 := (others=>'0');
  signal BRAM_ADDR : slv9  := (others=>'0');

begin
  
  BRAM : ram_1swsr_wfirst_gen
    generic map (
      AWIDTH =>  9,
      DWIDTH => 16)
    port map (
      CLK   => CLK,
      EN    => '1',
      WE    => BRAM_WE,
      ADDR  => BRAM_ADDR,
      DI    => IB_MREQ.din,
      DO    => BRAM_DO
    );

  BRAM_ADDR <= IB_MREQ.addr(12) & IB_MREQ.addr(8 downto 1);
  
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

  proc_next : process (R_REGS, IB_MREQ, BRAM_DO)
    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;
    variable idout : slv16 := (others=>'0');
    variable ibreq : slbit := '0';
    variable iback : slbit := '0';
    variable imemwe : slbit := '0';
  begin

    r := R_REGS;
    n := R_REGS;

    idout := (others=>'0');
    ibreq := IB_MREQ.re or IB_MREQ.we;
    iback := '0';
    imemwe := '0';
    
    -- ibus address decoder
    n.ibselcsr := '0';
    n.ibselmem := '0';
    if IB_MREQ.aval='1' then
      if IB_MREQ.addr(12 downto 1)=ibaddr_m9312_lo(12 downto 1) then
        n.ibselcsr := '1';   
      end if;
      if IB_MREQ.addr(12 downto 9)=ibaddr_m9312_lo(12 downto 9) or
         IB_MREQ.addr(12 downto 9)=ibaddr_m9312_hi(12 downto 9) then
        n.ibselmem := '1';   
      end if;
    end if;

    -- ibus transactions
    if IB_MREQ.racc = '1' then          -- rem side --------------------------
      if r.ibselcsr = '1' then            -- csr access
        idout(csr_ibf_locwe)  := r.locwe;
        idout(csr_ibf_enahi)  := r.enahi;
        idout(csr_ibf_enalo)  := r.enalo;
        if IB_MREQ.we = '1' then
          n.locwe := IB_MREQ.din(csr_ibf_locwe);
          n.enahi := IB_MREQ.din(csr_ibf_enahi);
          n.enalo := IB_MREQ.din(csr_ibf_enalo);
        end if;
        iback := ibreq;
      end if;

    else                                -- loc side --------------------------
      if r.ibselmem = '1' then            -- mem access
        idout := BRAM_DO;
        if IB_MREQ.re = '1' then            -- read request
          if IB_MREQ.addr(12) = '0' then      -- LO-ROM
            iback := r.enalo;                   -- ack if enabled
          else                                -- HI-ROM
            iback := r.enahi;                   -- ack if enabled
          end if;
        elsif IB_MREQ.we = '1' then         -- write request
          iback  := r.locwe;
          imemwe := r.locwe;
        end if;
      end if;
    end if; -- IB_MREQ.racc

    N_REGS <= n;
    
    BRAM_WE   <= imemwe;

    IB_SRES.dout <= idout;
    IB_SRES.ack  <= iback;
    IB_SRES.busy <= '0';
    
  end process proc_next;

    
end syn;
